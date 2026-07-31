#!/usr/bin/env python3
from blessed import Terminal

t = Terminal()
print("Press keys to see what they send. Ctrl+C to quit.\r")
with t.raw(), t.hidden_cursor():
    while True:
        k = t.inkey()
        codes = " ".join(hex(ord(c)) for c in k)
        print(f"repr={k!r}  name={k.name}  codes=[{codes}]\r")
        if k == "\x03":
            break
