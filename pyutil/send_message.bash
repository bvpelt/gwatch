#!/bin/bash

# Default to 10 if no argument is provided
MAX_MESSAGES=${1:-2}

URL="http://localhost:5000/send_message"

for ((i=1; i<=MAX_MESSAGES; i++))
do
   echo "Sending message $i..."
   curl -v -X POST $URL \
        -H "Content-Type: application/json" \
        -d "{\"type\": \"message\", \"sender\": \"bart\", \"text\": \"message $i\"}"
done