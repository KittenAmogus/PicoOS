import struct
import sys

if len(sys.argv) != 3:
    sys.stderr.write("Usage: python calculate-crc32.py boot2.raw.bin boot2.bin\n")
    sys.exit(1)

fin = sys.argv[1]
fout = sys.argv[2]

def rp2040_crc32(data: bytes) -> int:
    crc = 0xFFFFFFFF
    for byte in data:
        crc ^= byte << 24
        for _ in range(8):
            if crc & 0x80000000:
                crc = ((crc << 1) ^ 0x04C11DB7) & 0xFFFFFFFF
            else:
                crc = (crc << 1) & 0xFFFFFFFF
    return crc

with open(fin, "rb") as f:
    code = f.read()

if len(code) > 252:
    raise ValueError(f"boot2 code is {len(code)} bytes; must be <= 252 bytes")

padded = code.ljust(252, b"\x00")
crc = rp2040_crc32(padded)
boot2_img = padded + struct.pack("<I", crc)

with open(fout, "wb") as f:
    f.write(boot2_img)
