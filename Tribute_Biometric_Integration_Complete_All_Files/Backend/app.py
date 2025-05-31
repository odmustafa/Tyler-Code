from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import hashlib
import datetime

app = Flask(__name__)
CORS(app, origins=["http://localhost:3000"])  # Allow React dev server
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///tribute_users.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    membership_type = db.Column(db.String(50), default='Standard')
    fingerprint_template = db.Column(db.LargeBinary)
    created_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)
    last_login = db.Column(db.DateTime)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'email': self.email,
            'membership_type': self.membership_type,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'last_login': self.last_login.isoformat() if self.last_login else None
        }

# Create tables when app starts
with app.app_context():
    db.create_all()

def generate_template_from_scan(scan_data):
    import hashlib
    return hashlib.sha256(scan_data.encode()).digest()

def match_templates(template1, template2):
    return template1 == template2

@app.route('/register', methods=['POST'])
def register():
    try:
        data = request.json

        # Validate required fields
        if not data.get('name') or not data.get('email') or not data.get('fingerprint_scan'):
            return jsonify({"error": "Missing required fields"}), 400

        # Check if email already exists
        existing_user = User.query.filter_by(email=data['email']).first()
        if existing_user:
            return jsonify({"error": "Email already registered"}), 409

        template = generate_template_from_scan(data['fingerprint_scan'])
        new_user = User(
            name=data['name'],
            email=data['email'],
            membership_type=data.get('membership_type', 'Standard'),
            fingerprint_template=template
        )
        db.session.add(new_user)
        db.session.commit()

        return jsonify({
            "message": "User registered successfully",
            "user": new_user.to_dict()
        }), 201

    except Exception as e:
        db.session.rollback()
        return jsonify({"error": "Registration failed"}), 500

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        scan = data.get('fingerprint_scan')

        if not scan:
            return jsonify({"error": "Fingerprint scan required"}), 400

        template = generate_template_from_scan(scan)
        users = User.query.all()

        for user in users:
            if match_templates(user.fingerprint_template, template):
                # Update last login
                user.last_login = datetime.datetime.now(datetime.timezone.utc)
                db.session.commit()

                return jsonify({
                    "message": f"Welcome {user.name}",
                    "membership": user.membership_type,
                    "user": user.to_dict()
                }), 200

        return jsonify({"error": "No match found"}), 401

    except Exception as e:
        return jsonify({"error": "Authentication failed"}), 500

if __name__ == '__main__':
    app.run(debug=True)
