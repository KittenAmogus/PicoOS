import struct
import sys

def calculate_crc32(data):
    remainder = 0xffffffff
    polynomial = 0x04c11db7
    for byte in data:
        remainder ^= (byte << 24)
        for _ in range(8):
            if remainder & 0x80000000:
                remainder = ((remainder << 1) ^ polynomial) & 0xffffffff
            else:
                remainder = (remainder << 1) & 0xffffffff
    return remainder

if len(sys.argv) < 3:
    print("Usage: pad_checksum.py <input_raw.bin> <output_padded.bin>")
    sys.argv[1] = "boot2_raw.bin"
    sys.argv.append("boot2.bin")

with open(sys.argv[1], "rb") as f:
    raw_data = bytearray(f.read())

if len(raw_data) > 252:
    print(f"Error: Boot2 size ({len(raw_data)} bytes) exceeds 252 bytes limit!")
    sys.exit(1)

padded_data = raw_data + b'\x00' * (252 - len(raw_data))

crc = calculate_crc32(padded_data)
checksum_bytes = struct.pack("<I", crc)

with open(sys.argv[2], "wb") as f:
    f.write(padded_data + checksum_bytes)

print(f"--> Success! Boot2 CRC32: {hex(crc)}. Padded to 256 bytes.")
