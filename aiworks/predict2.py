from flask import Flask, request, jsonify
from flask_cors import CORS
import os
os.environ["OMP_NUM_THREADS"] = "4"
import pandas as pd
import numpy as np
from joblib import load
from datetime import datetime

app = Flask(__name__)
CORS(app)

# --------------------------
# Preprocessing Functions
# --------------------------
def preprocess_data(df):
    df['datetime'] = pd.to_datetime(df['timestamp'])
    # Temporal features
    df['hour'] = df['datetime'].dt.hour
    df['day_of_week'] = df['datetime'].dt.dayofweek
    df['month'] = df['datetime'].dt.month
    # Encode cyclical features
    df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24)
    df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24)
    df['day_sin'] = np.sin(2 * np.pi * df['day_of_week'] / 7)
    df['day_cos'] = np.cos(2 * np.pi * df['day_of_week'] / 7)
    return df.drop(['timestamp', 'datetime'], axis=1)

def create_spatial_features(df, kmeans_model):
    coords = df[['latitude', 'longitude']].values
    distances = kmeans_model.transform(coords)
    df['min_cluster_dist'] = distances.min(axis=1)
    # Get nearest cluster label
    df['cluster'] = kmeans_model.predict(coords)
    return df

# --------------------------
# Load Model Artifacts Once
# --------------------------
# These artifacts will be loaded once when the app starts.
ARTIFACTS = load('crime_prediction_model.joblib')
MODEL = ARTIFACTS['model']
KMEANS = ARTIFACTS['kmeans']
CLUSTER_SEVERITY = ARTIFACTS['cluster_severity']
SPATIAL_THRESHOLD = ARTIFACTS['spatial_threshold']
FEATURES = ARTIFACTS['features']

# --------------------------
# Vectorized Grid Prediction
# --------------------------
def batch_predict_severity(center_lat, center_lon, timestamp, ratio):
    """
    Build a grid of points around the given center and compute predictions for all points at once.
    """
    # Parameters for the grid (adjust as needed)
    n = 4           # grid extent: points will range from -n to +n in each direction
    delta = 0.001   # grid spacing in degrees (~111 meters per 0.001 degree of latitude)
    
    # Create grid data in a list of dicts
    data = []
    for i in range(-n, n + 1):
        for j in range(-n, n + 1):
            lat = center_lat + i * delta
            lon = center_lon + j * delta
            data.append({
                'latitude': lat,
                'longitude': lon,
                'timestamp': timestamp,
                'male-female-ratio': ratio
            })
    # Convert list to DataFrame
    df = pd.DataFrame(data)
    
    # Preprocess and add spatial features
    df = preprocess_data(df)
    df = create_spatial_features(df, KMEANS)
    
    # Determine which points are too far from training data
    mask = df['min_cluster_dist'] > SPATIAL_THRESHOLD
    
    # For points within the threshold, compute cluster-based features
    df.loc[~mask, 'cluster_severity'] = df.loc[~mask, 'cluster'].map(CLUSTER_SEVERITY)
    df.loc[~mask, 'severity_adjusted_ratio'] = np.where(
        df.loc[~mask, 'cluster_severity'] <= 3,
        df.loc[~mask, 'cluster_severity'],
        df.loc[~mask, 'male-female-ratio'] * df.loc[~mask, 'cluster_severity']
    )
    
    # Prepare predictions: default severity = 0.0 for points outside training data
    predictions = np.zeros(len(df))
    if (~mask).any():
        predictions[~mask] = MODEL.predict(df.loc[~mask, FEATURES])
    df['predicted_crime_severity'] = predictions
    return df

# --------------------------
# API Endpoint
# --------------------------
@app.route('/api_grid', methods=['POST'])
def receive_grid():
    data = request.get_json()
    center_lat = data.get('latitude')
    center_lon = data.get('longitude')
    timestamp = data.get('timestamp')
    ratio = data.get('male-female-ratio', 3.2)
    
    # Compute grid predictions in a vectorized way
    df = batch_predict_severity(center_lat, center_lon, timestamp, ratio)
    # Convert the DataFrame to a list of dicts (only sending back necessary columns)
    grid_points = df[['latitude', 'longitude', 'predicted_crime_severity']].to_dict(orient='records')
    return jsonify({'grid': grid_points})

# --------------------------
# Main Entrypoint
# --------------------------
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=12346)
