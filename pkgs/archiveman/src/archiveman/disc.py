import contextlib
import random
from archiveman import models, udflabel, util

DEFAULT_LVID = "UNTITLED ARCHIVEMAN VOLUME"
VID_PREFIX = "ARCHIVEMAN00."

def random_vid():
  chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return VID_PREFIX + "".join(random.choice(chars) for i in range(16))

def detect_disc(filename, session):
  _, vid = udflabel.parse_udf_labels(filename)
  if vid is None:
    print("archiveman: failed to extract volume ID from UDF image at {}".format(filename))
    util.abort()
  disc = session.query(models.Disc).filter_by(volume_id = vid).first()
  if disc is None:
    print("archiveman: invalid volume ID in UDF image at {}".format(filename))
    util.abort()
  return disc

@contextlib.contextmanager
def mount(udffile, mountpoint = "/tmp/archiveman-mount"):
  util.ensure_dir(mountpoint)
  cmd = ["mount", udffile, mountpoint]
  with util.execute(cmd):
    pass
  yield mountpoint
  cmd = ["umount", udffile]
  with util.execute(cmd):
    pass

def do_create(args, db, st):
  session = db.make_session()

  udf_file = args["<udffile>"]

  if args["--label"]:
    lvid = args["--label"]
  else:
    lvid = DEFAULT_LVID

  if args["--size"]:
    size = int(args["--size"])
  else:
    size = 25000000000 # 25 GB

  vid = random_vid()

  # 128 byte field, needs space for length (1 byte suffix) and UTF-8 indicator (1 byte prefix).
  if len(lvid) > 126:
    print("archiveman: disc label must be no longer than 126 characters")
    util.abort()

  # 32 byte field, same as above.
  assert len(vid) <= 30

  # Create Disc object in database.
  disc = models.Disc(volume_id = vid)
  session.add(disc)

  # Create parent directory.
  util.ensure_parent_dir(udf_file)

  # Set length of file to desired amount.
  cmd = ["truncate", "--size", str(size), udf_file]
  with util.execute(cmd):
    pass

  # Create UDF filesystem inside file.
  cmd = ["mkudffs", "--vid", vid, "--lvid", lvid, udf_file]
  with util.execute(cmd):
    pass

  session.commit()

def do_add(args, db, st):
  session = db.make_session()

  udffile = args["<udffile>"]

  if not os.path.exists(udffile):
    print("UDF file does not exist: {}".format(udffile))
    util.abort()

  disc = detect_disc(udffile, session)

  archives = []
  for archivename in args["<archivename>"]:
    archive = session.query(models.Archive).filter_by(name = archivename).first()
    if archive is None:
      print("reference to unknown archive: {}".format(archivename))
      util.abort()
    archives.append(archive)

  with mount(udffile) as mountpoint:
    for archive in archives:
      dest_filename = os.path.join(mountpoint, archive.name)
      st.copy_to(archive, dest_filename)

      

def handle_cmdline(args, db, st):
  if args["create"]:
    do_create(args, db, st)
  else:
    logger.error("no operation specified")
    util.abort()
