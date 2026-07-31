#!/usr/bin/env bash

# Check if port 9999 is already listening (works using standard ss or netstat)
if ss -tuln | grep -q ":9999 "; then
  # Server is already running somewhere else, exit immediately and do nothing!
  exit 0
fi

# If the port is free, start the listener exactly once
python3 -c '
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 9999))
s.listen(1)
try:
    conn, addr = s.accept()
    print(conn.recv(1024).decode("utf-8").strip(), flush=True)
    conn.close()
finally:
    s.close()
'
