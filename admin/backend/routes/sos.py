from flask import Blueprint, request, jsonify
import csv
import os

sos_routes = Blueprint('sos_routes', __name__)

# Path to crime history CSV file
CRIME_HISTORY_FILE = "women_crime_data_2.csv"

@sos_routes.route('/api/review-sos', methods=['POST'])
def review_sos():
    data = request.json
    sos_id = data.get("sosId")
    latitude = data.get("latitude")
    longitude = data.get("longitude")

    if not sos_id or not latitude or not longitude:
        return jsonify({"error": "Missing data"}), 400

    # Append to crime history CSV
    file_exists = os.path.isfile(CRIME_HISTORY_FILE)
    with open(CRIME_HISTORY_FILE, mode='a', newline='') as file:
        writer = csv.writer(file)
        if not file_exists:
            writer.writerow(["latitude", "longitude"])  # Write header if file is new
        writer.writerow([latitude, longitude])

    return jsonify({"message": "SOS location added to crime history"}), 200
