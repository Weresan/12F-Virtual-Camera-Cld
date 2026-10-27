"""Render the project-native aperture mark; stdlib only, opaque iOS icon."""
import json
import math
import struct
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
folder = ROOT / 'ios/VirtualCamera/Assets.xcassets/AppIcon.appiconset'
folder.mkdir(parents=True, exist_ok=True)
size = 1024
rows = []
for y in range(size):
    row = bytearray()
    for x in range(size):
        dx, dy = x - 511.5, y - 511.5
        radius = math.hypot(dx, dy)
        # Circular iris with six swept blades and an open hexagonal center.
        sector = (math.atan2(dy, dx) + math.pi) % (math.pi / 3)
        blade = 155 < radius < 300 and abs(radius * math.sin(sector - 0.30) - 95) < 11
        ink = 284 < radius < 307 or blade
        row.extend((56, 145, 255) if ink else (23, 36, 59))
    rows.append(b'\0' + row)

def chunk(kind, data):
    return struct.pack('!I', len(data)) + kind + data + struct.pack('!I', zlib.crc32(kind + data))

png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', struct.pack('!2I5B', size, size, 8, 2, 0, 0, 0))
png += chunk(b'IDAT', zlib.compress(b''.join(rows), 9)) + chunk(b'IEND', b'')
(folder / 'AppIcon.png').write_bytes(png)
(folder / 'Contents.json').write_text(json.dumps({'images': [{'filename': 'AppIcon.png', 'idiom': 'universal', 'platform': 'ios', 'size': '1024x1024'}], 'info': {'author': '12F Development Team', 'version': 1}}, indent=2))
(folder.parent / 'Contents.json').write_text('{"info":{"author":"12F Development Team","version":1}}')
print(folder / 'AppIcon.png')
