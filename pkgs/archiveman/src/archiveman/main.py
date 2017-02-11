"""Archive management tool.

Usage:
  archiveman import <archivename> <sourcefile>
  archiveman list
  archiveman check
  archiveman disc create <udffile> [--label=<label>] [--size=<bytes>]
  archiveman disc add <udffile> <archivename>...
"""

import docopt
import logging
import os.path
from archiveman import archivecopy, database, disc, models, store, util

def do_import(args, db, st):
  name = args["<archivename>"]
  source_file = args["<sourcefile>"]

  logger = logging.getLogger("archiveman.do_import")
  session = db.make_session()

  # Check no archive with given name exists in database.
  if session.query(models.Archive).filter_by(name = name).count() != 0:
    logger.error("an archive named '{}' already exists in the database".format(name))
    util.abort()

  # Check source file exists.
  if not os.path.exists(source_file):
    logger.error("file to import does not exist: {}".format(source_file))
    util.abort()

  checksum = util.checksum_file(source_file)
  logger.info("checksum is {}".format(checksum.decode("ascii")))

  # Go ahead and add archive to database.
  logger.info("adding '{}' to database".format(name))
  archive = models.Archive(name = name, checksum = checksum)
  session.add(archive)
  session.commit()

  # Import source file into store.
  logger.info("importing '{}' into store".format(source_file))
  st.copy_from(archive, source_file)

def do_list(args, db, st):
  logger = logging.getLogger("archiveman.do_list")
  session = db.make_session()

  for archive in session.query(models.Archive):
    print(archive.name)

def do_check(args, db, st):
  logger = logging.getLogger("archiveman.do_check")
  session = db.make_session()

  def colourise_boolean(x):
    if x:
      return util.colourise("YES", util.GREEN)
    else:
      return util.colourise("NO", util.RED)

  def colourise_num_copies(n):
    colour = [util.RED, util.YELLOW, util.GREEN][min(n, 2)]
    return util.colourise(str(n), colour)

  for archive in session.query(models.Archive):
    print(archive.name)

    copies = list(archivecopy.Copy.enumerate(archive, st))
    num_copies = len(copies)
    num_remote_copies = sum(1 for copy in copies if copy.is_remote)
    print("  copies: {} ({} local + {} remote)".format(
      colourise_num_copies(num_copies),
      num_copies - num_remote_copies,
      colourise_num_copies(num_remote_copies),
    ))

    for copy in copies:
      if isinstance(copy, archivecopy.StoreCopy):
        print("  copy in local store:")
        print("    location: {}".format(copy.filename))

      is_healthy = copy.is_healthy
      is_healthy_str = "UNKNOWN" if is_healthy is None else colourise_boolean(is_healthy)
      print("    healthy: {}".format(is_healthy_str))

def handle_cmdline(args, db, st):
  if args["import"]:
    do_import(args, db, st)
  elif args["list"]:
    do_list(args, db, st)
  elif args["check"]:
    do_check(args, db, st)
  elif args["disc"]:
    disc.handle_cmdline(args, db, st)
  else:
    logger.error("no operation specified")
    util.abort()

def main():
  logging.basicConfig(format="%(levelname)s:%(name)s: %(message)s")
  logging.getLogger().setLevel(logging.INFO)

  logger = logging.getLogger("archiveman")

  # Read command line arguments.
  args = docopt.docopt(__doc__)

  db = database.Database("sqlite:///archiveman.db")
  st = store.Store("archiveman-store")

  handle_cmdline(args, db, st)
