import sys
import subprocess

def main():
  if len(sys.argv) < 2:
    print >> sys.stderr, "usage: passchars <password> <index>..."
    sys.exit(2)

  cmd = ["pass", sys.argv[1]]
  p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
  stdout, _ = p.communicate()
  if p.returncode != 0:
    sys.exit(p.returncode)

  password = stdout.strip()

  for arg in sys.argv[2:]:
    index = int(arg)
    print password[index-1]
