import struct
import sys

REMAINDER  = 0xFFFFFFFF
POLYNOMIAL = 0x04C11DB7

def calculate_crc32(data):
    rem = REMAINDER
    for byte in data:
        rem ^= (byte << 24)
        for _ in range(8):
            if (rem & 0x80000000):
                rem = ((rem << 1) ^ POLYNOMIAL) & 0xFFFFFFFF
            else:
                rem = (rem << 1) & 0xFFFFFFFF
    return rem

if (len(sys.argv) < 3):
    print("Usage: check.py <input.bin> <output.bin>")
    sys.exit(1)

with open(sys.argv[1], "rb") as f:
    raw = bytearray(f.read())

if (len(raw) > 252):
    print(f"Error: boot2 size mismatch, {len(raw)} > 252")
    sys.exit(2)

padded = raw + (b'\x00' * (252 - len(raw)))
crc = calculate_crc32(padded)
check = struct.pack("<I", crc)

with open(sys.argv[2], "wb") as f:
    f.write(padded + check)

print(f"==> All done, CRC: {hex(crc)}")

