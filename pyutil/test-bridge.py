#!/usr/bin/env python3
from flask import Flask, request, jsonify
from flask_cors import CORS
import subprocess
import json
import socket

app = Flask(__name__)
CORS(app)

# Store the simulator's address
SIMULATOR_HOST = 'localhost'
SIMULATOR_PORT = 1234  # Port where simulator listens

messages = []

@app.route('/send_message', methods=['POST'])
def send_message():
    """Receive message from Android app"""
    print(f"Receive message from Android app")
    data = request.json
    print(f"Received message: {data}")
    messages.append(data)
    
    # Send to Garmin simulator via monkeydo
    try:
        # Format for simulator
        msg_json = json.dumps(data)
        print(f"Sending to watch: {msg_json}")
        
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((SIMULATOR_HOST, SIMULATOR_PORT))
        sock.sendall(str(data).encode())
        sock.close()

        # This simulates sending a phone app message
        # You'll need to trigger it in the simulator manually
        return jsonify({"status": "success", "message": "Message queued"}), 200
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500

@app.route('/messages', methods=['GET'])
def get_messages():
    """Get all messages"""
    return jsonify(messages)

@app.route('/clear', methods=['POST'])
def clear_messages():
    """Clear all messages"""
    messages.clear()
    return jsonify({"status": "success"})

if __name__ == '__main__':
    print("Starting bridge server on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)