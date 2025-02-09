from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_jwt_extended import create_access_token, jwt_required, JWTManager
from flask_cors import CORS
from flask_login import LoginManager, UserMixin, login_user, logout_user, current_user

app = Flask(__name__)
CORS(app)  # Allow frontend to access the API

# Database Configuration
app.config["SQLALCHEMY_DATABASE_URI"] = "sqlite:///police.db"  # Using SQLite for simplicity
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["SECRET_KEY"] = "supersecretkey"  # Change this in production
app.config["JWT_SECRET_KEY"] = "jwtsecretkey"

db = SQLAlchemy(app)
bcrypt = Bcrypt(app)
jwt = JWTManager(app)
login_manager = LoginManager(app)

# Police Model
class Police(db.Model, UserMixin):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    phone = db.Column(db.String(20), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)

@login_manager.user_loader
def load_user(police_id):
    return Police.query.get(int(police_id))

# API Endpoint: Police Registration
@app.route("/api/register", methods=["POST"])
def register():
    data = request.json
    hashed_password = bcrypt.generate_password_hash(data["password"]).decode("utf-8")
    new_police = Police(name=data["name"], phone=data["phone"], password=hashed_password)
    
    db.session.add(new_police)
    db.session.commit()
    return jsonify({"message": "Registration successful!"}), 201

# API Endpoint: Police Login
@app.route("/api/login", methods=["POST"])
def login():
    data = request.json
    police = Police.query.filter_by(phone=data["phone"]).first()
    
    if police and bcrypt.check_password_hash(police.password, data["password"]):
        access_token = create_access_token(identity=police.id)
        return jsonify({"message": "Login successful!", "token": access_token})
    
    return jsonify({"error": "Invalid credentials"}), 401

# API Endpoint: Fetch SOS Requests (Requires Authentication)
@app.route("/api/sos", methods=["GET"])
@jwt_required()
def get_sos_requests():
    fake_sos_data = [
        {"username": "Alice Smith", "phone": "9876543210", "address": "123 Street, NY", "latitude": "40.7128", "longitude": "-74.0060", "timestamp": "2024-02-08T10:30:00", "status": "Pending"},
        {"username": "Bob Johnson", "phone": "8765432109", "address": "456 Ave, LA", "latitude": "34.0522", "longitude": "-118.2437", "timestamp": "2024-02-08T10:35:00", "status": "Resolved"},
        {"username": "Charlie Brown", "phone": "7654321098", "address": "789 Blvd, TX", "latitude": "29.7604", "longitude": "-95.3698", "timestamp": "2024-02-08T10:40:00", "status": "Pending"}
    ]
    return jsonify(fake_sos_data)

if __name__ == "__main__":
    with app.app_context():
        db.create_all()  # Create tables
    app.run(debug=True)
