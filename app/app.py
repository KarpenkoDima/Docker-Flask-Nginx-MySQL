from flask import Flask, jsonify, request
import mysql.connector
import os
import time

app = Flask(__name__)

# Config DB
DB_CONFIG ={
    'host': os.getenv('DB_HOST', 'mysql-container'),
    'user': os.getenv('DB_USER', 'myuser'),
    'password': os.getenv('DB_PASSWORD', 'mypassword'),
    'database': os.getenv('DB_NAME', 'myapp'),
    'port' : 3306
}

def get_db_connection():
    """Connection to DB from retries"""
    max_retries = 10
    for i in range(max_retries):
        try:
            conn = mysql.connector.connect(**DB_CONFIG)
            return conn
        except mysql.connector.Error as e:
            print(f"Retrie {i+1}: Error connection to DB {e}")
            time.sleep(2)
    raise Exception("Unable to connect to the database")

@app.route('/')
def home():
    return jsonify({
        'message': 'Hello from Flask',
        'status' : 'working'
    })


@app.route('/health')
def health():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        cursor.fetchone()
        cursor.close()
        conn.close()
        return jsonify({'status': 'healthy', 'database': 'connected'})
    except Exception as e:
        return jsonify({'status': 'unhealthy', 'error': str(e)}), 500

@app.route('/users', methods=['GET'])
def get_users():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM users")
        users = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify(users)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/users', methods=['POST'])
def add_user():
    try:
        data = request.json
        name = data.get('name')
        email = data.get('email')
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("INSERT INTO users (name, email) VALUES (%s, %s)", (name, email))
        conn.commit()
        user_id = cursor.lastrowid
        cursor.close()
        conn.close()
        
        return jsonify({'id': user_id, 'name': name, 'email': email}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)