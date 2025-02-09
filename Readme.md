# Women Safety Analytics - Documentation

## Table of Contents
1. Introduction
2. Features
3. Tech Stack
4. System Architecture
5. Folder Structure
6. Installation and Setup
7. Backend API Endpoints
8. Frontend Overview
9. AI Model Integration
10. Real-Time Location Sharing
11. Admin Panel for Police
12. Future Enhancements

---

## 1. Introduction
Women Safety Analytics is a comprehensive web and mobile application designed to enhance personal safety by utilizing cutting-edge technology. The application offers real-time location tracking, crime zone classification using machine learning, and emergency alert broadcasting. Users can share their live location with trusted friends during emergencies, while law enforcement can monitor high-risk areas based on historical crime data.

## 2. Features
✅ **User Authentication:** Secure signup, login, and logout functionality with JWT authentication.  
✅ **Friend Management:** Users can add, invite, and remove friends who can track their location in emergencies.  
✅ **Real-time Live Location Tracking:** Users' locations are updated in real time and visible to their selected contacts.  
✅ **AI-Based Crime Zone Classification:** The system categorizes areas into Red, Yellow, and Green zones based on historical crime data.  
✅ **Automatic Alerts:** When a user enters a dangerous zone, an automatic alert is broadcasted to their friends.  
✅ **Emergency Call Feature:** Users can quickly contact emergency services like police and ambulances.  
✅ **Suspicious Gesture Detection:** The app detects sudden movements or distress gestures and triggers alerts.  
✅ **Image and Voice Clip Sharing:** Users can send images or voice clips during emergencies for additional context.  
✅ **Persistent Login Sessions:** Users remain logged in even after closing the app until they manually log out.  
✅ **Admin Panel for Law Enforcement:** Police officials can mark crime-prone areas and update historical crime records.  

## 3. Tech Stack
- **Frontend:** Flutter (Dart-based mobile app)
- **Backend:** Node.js with Express.js
- **Database:** MongoDB (using Change Streams for real-time updates)
- **AI Model:** Python (ML-based crime zone classification)
- **Real-Time Communication:** Socket.io
- **Notification Services:** Twilio (SMS alerts to friends and emergency contacts)
- **Authentication:** JWT (JSON Web Tokens) for secure login sessions

## 4. System Architecture
```
Frontend (Flutter)  <-->  Backend (Express.js)  <-->  Database (MongoDB)
                      |                             |
                polling                   AI Model (Python)
                    |                             |
                 Admin Panel                 CSV-based Crime Data
```
- The **frontend** is a Flutter-based mobile application providing an interactive UI.
- The **backend** processes authentication, friend management, and location tracking.
- The **database** stores user and crime data, with real-time updates for location tracking.
- The **AI model** classifies areas into safety zones using historical crime records.
- **Socket.io** ensures real-time communication between users and their friends.
- **Admin panel** allows law enforcement to mark crime locations and update the CSV file used for AI analysis.

## 5. Folder Structure
```
women-safety-analytics/
│── frontend/          # Flutter mobile app
│── backend/           # Node.js & Express.js API
│── ai-model/          # Python-based ML models
│── admin/             # Admin panel for crime history updates
│── docs/              # Documentation
```

## 6. Installation and Setup
### Prerequisites
- Node.js & npm
- MongoDB
- Python (for AI model processing)
- Flutter SDK (for mobile app development)

### Backend Setup
```sh
cd backend
npm install
npm start
```

### Frontend Setup
```sh
cd frontend
flutter pub get
flutter run
```

### AI Model Setup
```sh
cd ai-model
pip install -r requirements.txt
python model.py
```

### Admin Panel Setup
```sh
cd admin
npm install
npm start
```

## 7. Backend API Endpoints
### Authentication
- `POST /api/auth/signup` - Register a new user
- `POST /api/auth/login` - Login user

### Friends Management
- `POST /api/friends/add` - Add a friend
- `DELETE /api/friends/remove` - Remove a friend

### Location Tracking
- `POST /api/location/update` - Update user location
- `GET /api/location/live/:userId` - Fetch live location

### Alerts
- `POST /api/alert/send` - Trigger emergency alert

### Admin Panel
- `POST /api/admin/report` - Police report a crime location
- `GET /api/admin/locations` - Fetch crime locations

## 8. Frontend Overview
- **Flutter-based mobile application** providing seamless user experience.
- **Socket.io-client** is used for real-time updates and location sharing.
- **Material UI components** ensure an intuitive and accessible design.

## 9. AI Model Integration
- **Python-based ML model** analyzes historical crime data to classify locations into safety zones.
- A **Flask API** serves AI model predictions, which the backend fetches periodically.
- Crime records are maintained in a CSV file and updated dynamically through the admin panel.
- Users receive alerts based on AI-determined safety zones in real time.

## 10. Real-Time Location Sharing
- **Implemented using Socket.io** to allow live location tracking in emergency situations.
- Users can **create rooms** where friends can join and monitor their live location.
- Friends receive notifications via SMS or push notifications when a user enters a danger zone.
- Live location sharing can be toggled on/off by the user for privacy.

## 11. Admin Panel for Police
- The **admin panel** is designed specifically for law enforcement officials.
- Police officers can **report new crime locations** that get added to the AI model's dataset.
- Locations are stored in a **CSV file** that is periodically processed by the AI model.
- Officials can view **crime heatmaps** and suggest areas for increased patrolling.
- The panel includes an **authentication system** to prevent unauthorized access.

## 12. Future Enhancements
- **Deployment of the Flutter app** to Play Store/App Store for wider reach.
- **Improved AI Model** with advanced crime prediction algorithms.
- **Integration with Smart Devices** like smartwatches for automatic distress signal detection.
- **Voice Command Feature** to trigger emergency alerts without unlocking the phone.
- **Direct API Integration with Law Enforcement Databases** for real-time incident reporting.
- **Machine Learning Model Upgrades** to adapt to changing crime patterns dynamically.

This documentation provides a detailed overview of the Women Safety Analytics system, ensuring clear understanding for developers, law enforcement, and end users. 🚀

