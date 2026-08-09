#!/usr/bin/env bash

# start kitty server so pyhist opens faster
if ! pgrep -f "kitty.*--instance-group=pyhist" >/dev/null; then
  kitty --start-as=hidden -1 --instance-group=pyhist &
fi

# Own port (9998), distinct from pytab's 9999, so a live Pytab session
# and a live Pyhist session can never race for the same listener.
if ss -tuln | grep -q ":9998 "; then
  exit 0
fi

# Listen once, for at most 10 minutes -- same self-cleanup rationale as
# pytab's server: if the extension side ever dies mid-session, this exits
# on its own instead of hanging around forever.
python3 -c '
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 9998))
s.listen(1)
s.settimeout(600)
try:
    conn, addr = s.accept()
    conn.settimeout(5)
    chunks = []
    while True:
        chunk = conn.recv(4096)
        if not chunk:
            break
        chunks.append(chunk)
    print(b"".join(chunks).decode("utf-8").strip(), flush=True)
    conn.close()
except socket.timeout:
    pass
finally:
    s.close()
'
