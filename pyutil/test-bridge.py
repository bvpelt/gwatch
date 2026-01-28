#!/usr/bin/env python3
from flask import Flask, request, jsonify
from flask_cors import CORS
import requests 
import subprocess
import json
import socket

app = Flask(__name__)
CORS(app)

# Store the simulator's address
SIMULATOR_HOST = 'localhost'
SIMULATOR_PORT = 1234  # Port where simulator listens
SIMULATOR_API = "http://localhost:1234/api/communications"

messages = []

# Path to your .prg file
PRG_PATH = "/home/bvpelt/Develop/gwatch/build/MessengerApp.prg"
DEVICE = "fr165"


# Option 3
@app.route('/send_messagez', methods=['POST'])
def send_messagez():
    data = request.json
    print(f"Received message: {data}")
    messages.append(data)
    
    try:
        # Try to use simulator's HTTP API
        response = requests.post(
            SIMULATOR_API,
            json=data,
            timeout=5
        )
        
        if response.status_code == 200:
            return jsonify({"status": "success"}), 200
        else:
            return jsonify({"status": "error", "message": "Simulator rejected message"}), 500
    except requests.exceptions.ConnectionError:
        return jsonify({"status": "error", "message": "Simulator not responding"}), 500
    except Exception as e:
        return jsonify({"status": "error", "message": str(e)}), 500

# Option 1
@app.route('/send_message', methods=['POST'])
def send_message():
    """Receive message from Android app and send to watch simulator"""
    print("Receive message from Android app")
    data = request.json
    print(f"Received message: {data}")
    messages.append(data)
    
    try:
        # Format message for simulator
        msg_json = json.dumps(data)
        print(f"Sending to watch: {msg_json}")
        
        # Use monkeydo to push the communication message
        # The simulator must already be running
        cmd = [
            "monkeydo",
            PRG_PATH,
            DEVICE,
            "--push-message",
            msg_json
        ]
        
        print(f"Running command: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=5)
        
        if result.returncode == 0:
            print("Message sent successfully")
            return jsonify({"status": "success", "message": "Message sent to watch"}), 200
        else:
            print(f"Error sending message: {result.stderr}")
            return jsonify({"status": "error", "message": result.stderr}), 500
            
    except subprocess.TimeoutExpired:
        return jsonify({"status": "error", "message": "Command timeout"}), 500
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"status": "error", "message": str(e)}), 500



@app.route('/send_messagex', methods=['POST'])
def send_messagex():
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