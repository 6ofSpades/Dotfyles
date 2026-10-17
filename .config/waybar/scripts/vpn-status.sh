#!/bin/bash

# Run protonvpn-cli status and capture output
STATUS_OUTPUT=$(protonvpn status 2>/dev/null)

# Check if the output indicates an active connection
# (adjust the keyword if your version outputs something slightly different like "Connected")
if echo "$STATUS_OUTPUT" | grep -qE "Connected|Status: Connected"; then
  # Optional: Extract server name if you want it on the bar, or just keep it clean
  SERVER=$(echo "$STATUS_OUTPUT" | grep -i "Server:" | awk '{print $2}')

  # echo $SERVER

  echo "{\"text\": \"  $SERVER\", \"class\": \"connected\", \"tooltip\": \"Connected to ProtonVPN\"}"
else
  echo "{\"text\": \"  VPN\", \"class\": \"disconnected\", \"tooltip\": \"Disconnected\"}"
fi
