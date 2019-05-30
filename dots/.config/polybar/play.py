import os

try:
    val = os.popen('playerctl status').read()
except Exception:
    val = 0

if val == 'Playing\n':
    print('')
else:
    print('')
