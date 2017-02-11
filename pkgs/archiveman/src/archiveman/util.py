import contextlib
import logging
import os
import shlex
import subprocess
import sys

def abort():
  sys.exit(1)

RED = "\x1b[1;31m"
GREEN = "\x1b[1;32m"
YELLOW = "\x1b[1;33m"
RESET = "\x1b[21;39m"

def colourise(text, colour):
  if sys.stdout.isatty():
    return colour + text + RESET
  else:
    return text

@contextlib.contextmanager
def execute(command):
  logger = logging.getLogger("archiveman.execute")
  command_str = " ".join(shlex.quote(arg) for arg in command)
  logger.info(command_str)
  p = subprocess.Popen(command, stdout = subprocess.PIPE)
  try:
    yield p
  finally:
    p.wait()

def checksum_file(filename):
  cmd = ["sha256sum", "--binary", filename]
  with execute(cmd) as p:
    output = p.stdout.read()
  return output[:64]

def ensure_dir(dir):
  if dir != "":
    os.makedirs(dir, mode = 0o755, exist_ok = True)

def ensure_parent_dir(path):
  ensure_dir(os.path.dirname(path))
