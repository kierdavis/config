import struct

def decode_dstring(data, charset):
  # Extract string length and trim to correct size.
  length, = struct.unpack("<B", data[-1:])
  data = data[:length]

  # Charset "decoding". We only handle CS0, which
  # basically means "unspecified".
  charset_type, = struct.unpack("<B", charset[0:1])
  assert charset_type == 0

  # Clean up after mkudffs's odd unicode encodings.
  if data.startswith(b"\x08"):
    data = data[1:].decode("utf-8")
  elif data.startswith(b"\x10"):
    data = data[1:].decode("utf-16")
  else:
    data = data.decode("ascii")

  return data

def parse_udf_labels(filename):
  logical_sector_size = 2048

  lvid = None # Logical Volume Identifier
  vid = None  # Volume Identifier

  with open(filename, "rb") as f:
    # Read the Anchor Volume Descriptor Pointer descriptor, located at sector 256
    f.seek(logical_sector_size * 256)
    avdp_descriptor = f.read(32)
    # Check that the validity of this descriptor.
    avdp_identifier, = struct.unpack("<H", avdp_descriptor[0:2])
    if avdp_identifier != 0x0002:
      return None, None
    # Extract the location of the Main Volume Descriptor Sequence.
    mvds_location, = struct.unpack("<I", avdp_descriptor[20:24])

    # Loop over the descriptors in the Main Volume Descriptor Sequence.
    pos = mvds_location
    for i in range(32): # Stop after 32 sectors to prevent infinite looping.
      # Read the descriptor.
      f.seek(logical_sector_size * pos)
      descriptor = f.read(512)
      # Determine what kind of descriptor this is.
      identifier, = struct.unpack("<H", descriptor[0:2])
      if identifier == 0x0008: # Terminating Descriptor
        # This descriptor indicates the end of the Main Volume Descriptor Sequence.
        break
      elif identifier == 0x0001: # Primary Volume Descriptor
        # Extract the volume ID, and the charset information.
        charset = descriptor[200:264]
        raw_vid = descriptor[24:56]
        #raw_vsid = descriptor[72:200]
        # Decode the volume ID.
        vid = decode_dstring(raw_vid, charset)
      elif identifier == 0x0006: # Logical Volume Descriptor
        # Extract the logical volume ID, and the charset, and the charset information.
        charset = descriptor[20:84]
        raw_lvid = descriptor[84:212]
        # Decode the logical volume ID
        lvid = decode_dstring(raw_lvid, charset)
      else:
        # If any other descriptor, skip it.
        pass
      # Move on to the next sector (which contains the next descriptor).
      pos += 1

  return lvid, vid

if __name__ == "__main__":
  import sys
  print(parse_udf_labels(sys.argv[1]))
