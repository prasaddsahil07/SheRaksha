from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import numpy as np
from sklearn.cluster import KMeans
from sklearn.ensemble import RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline
from joblib import dump, load
from datetime import datetime
from sklearn.metrics import mean_absolute_error, mean_squared_error

app = Flask(__name__)
CORS(app)

def preprocess_data(df):
    df['datetime'] = pd.to_datetime(df['timestamp'])

    #temporal features
    df['hour'] = df['datetime'].dt.hour
    df['day_of_week'] = df['datetime'].dt.dayofweek
    df['month'] = df['datetime'].dt.month

    #encoding for the above
    df['hour_sin'] = np.sin(2 * np.pi * df['hour']/24)
    df['hour_cos'] = np.cos(2 * np.pi * df['hour']/24)
    df['day_sin'] = np.sin(2 * np.pi * df['day_of_week']/7)
    df['day_cos'] = np.cos(2 * np.pi * df['day_of_week']/7)

    return df.drop(['timestamp','datetime'], axis=1)

def create_spatial_features(df, kmeans_model):
    coords = df[['latitude', 'longitude']].values
    distances = kmeans_model.transform(coords)
    df['min_cluster_dist'] = distances.min(axis=1)

    # Get nearest cluster label
    df['cluster'] = kmeans_model.predict(coords)

    return df

def predict_severity(input_data):
    # Load model and artifacts
    artifacts = load('crime_prediction_model.joblib')
    model = artifacts['model']
    kmeans = artifacts['kmeans']
    cluster_severity = artifacts['cluster_severity']
    spatial_threshold = artifacts['spatial_threshold']
    features = artifacts['features']


    # Create DataFrame from input
    df = pd.DataFrame([input_data])
    df = preprocess_data(df)
    df = create_spatial_features(df, kmeans)

    print(df['min_cluster_dist'].values)  #given here for checking purpose
    print(df['cluster'].values)

    if df['min_cluster_dist'].iloc[0] > spatial_threshold:
        # print("Location is far away from training data. Returning 0 severity.")
        return 0.0

    # Add cluster-based features
    df['cluster_severity'] = df['cluster'].map(cluster_severity)
    # df['severity_adjusted_ratio'] = df['male-female-ratio'] * df['cluster_severity']
    print(df['cluster_severity'].values)

    df['severity_adjusted_ratio'] = np.where(
        df['cluster_severity'] <= 3,
        df['cluster_severity'],
        df['male-female-ratio'] * df['cluster_severity']
    )


    return model.predict(df[features])[0]

@app.route('/api', methods=['POST'])
def receive_location():
    data = request.get_json()
    latitude = data.get('latitude')
    longitude = data.get('longitude')
    timestamp = data.get('timestamp')

    print(f"Received location: Latitude = {latitude}, Longitude = {longitude}, time = {timestamp}")

    # Prepare input data for prediction
    input_data = {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp,  # Or get timestamp from request
        'male-female-ratio': 3.2
    }

    # Make prediction
    prediction = predict_severity(input_data)

    # Return prediction as JSON
    return jsonify({'latitude':latitude,'longitude':longitude,'predicted_crime_severity': prediction}) #returning all values

# @app.route('/api_grid', methods=['POST'])
# def receive_grid():
#     data = request.get_json()
#     center_lat = data.get('latitude')
#     center_lon = data.get('longitude')
#     timestamp = data.get('timestamp')
#     ratio = data.get('male-female-ratio', 1.7)
    
#     grid_points = []
#     # Define grid parameters:
#     # Use n = 3 to generate points from -3 to 3 in both lat and lon (7 points each axis = 49 points).
#     n = 3  
#     # 2 km radius roughly equals 0.018° (since 1° ~ 111 km)
#     delta = 0.004 / n  # step size in degrees
#     for i in range(-n, n+1):
#         for j in range(-n, n+1):
#             lat = center_lat + i * delta
#             lon = center_lon + j * delta
#             input_data = {
#                 'latitude': lat,
#                 'longitude': lon,
#                 'timestamp': timestamp,
#                 'male-female-ratio': ratio
#             }
#             severity = predict_severity(input_data)
#             grid_points.append({
#                 'latitude': lat,
#                 'longitude': lon,
#                 'predicted_crime_severity': severity
#             })
#     return jsonify({'grid': grid_points})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0',port=12345)
