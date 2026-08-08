#!/usr/bin/env bash

# start kitty server so pytab opens faster
if ! pgrep -f "kitty.*--instance-group=pytab" >/dev/null; then
  kitty --start-as=hidden -1 --instance-group=pytab &
fi

# Check if port 9999 is already listening (another iteration of the loop
# already owns it -- this only happens if two calls race, which should be
# rare now that the loop is started on-demand instead of via TriStart).
if ss -tuln | grep -q ":9999 "; then
  exit 0
fi

# Listen once, for at most 10 minutes. The timeout means that if this
# process ever gets orphaned (e.g. the extension side dies mid-session
# without sending a stop signal), it exits on its own instead of sitting
# around forever waiting for a connection that will never come.
python3 -c '
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", 9999))
s.listen(1)
s.settimeout(600)
try:
    conn, addr = s.accept()
    conn.settimeout(5)
    print(conn.recv(1024).decode("utf-8").strip(), flush=True)
    conn.close()
except socket.timeout:
    pass
finally:
    s.close()
'
