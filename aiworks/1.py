import pandas as pd
import random
from datetime import datetime, timedelta

# Function to generate random timestamps
def random_timestamp(start, end):
    return start + timedelta(seconds=random.randint(0, int((end - start).total_seconds())))

# Define parameters
num_entries = 1000

# Define ranges for latitude and longitude within Kolkata area
latitude_range = (22.9000, 23.0000)  # Approximate range for Adi Saptagram
longitude_range = (88.3000, 88.4500)  # Approximate range for Adi Saptagram

# Define ranges for male-female ratio
male_female_ratio_range = (0.3, 4.0)  # Range of male-female ratios

# Initialize lists for data
data = []

# Define date range for timestamps
start_date = datetime(2024, 11, 1)
end_date = datetime(2025, 1, 31)

# Generate data
for _ in range(num_entries):
    # Generate random latitude and longitude within specified ranges
    latitude = round(random.uniform(*latitude_range), 6)
    longitude = round(random.uniform(*longitude_range), 6)
    
    # Generate a random male-female ratio within specified range
    male_female_ratio = round(random.uniform(*male_female_ratio_range), 2)
    
    # Higher male-female ratio contributes to higher crime severity
    crime_severity = min(10, int(male_female_ratio * random.uniform(1, 3)))  # Scale severity based on ratio
    
    # Generate timestamps; more crimes at night (20:00 to 01:59)
    if random.random() < 0.6:
        timestamp = random_timestamp(datetime.combine(start_date.date(), datetime.min.time()) + timedelta(hours=20),
                                     datetime.combine(start_date.date(), datetime.min.time()) + timedelta(days=1, hours=1, minutes=59))
    else:
        timestamp = random_timestamp(start_date, end_date.replace(hour=19))  # Daytime until 19:00

    # Append to data list
    data.append([latitude, longitude, crime_severity, male_female_ratio, timestamp])

# Create DataFrame and save to CSV
df = pd.DataFrame(data, columns=['latitude', 'longitude', 'crime-severity', 'male-female-ratio', 'timestamp'])
df.to_csv('women_crime_data_2.csv', index=False)

print("CSV file 'women_crime_data_2.csv' generated successfully.")
