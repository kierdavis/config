import sys
import subprocess

def main():
  if len(sys.argv) < 2:
    print("usage: passchars <password> <index>...", file=sys.stderr)
    sys.exit(2)

  cmd = ["pass", sys.argv[1]]
  password = subprocess.run(cmd, stdout=subprocess.PIPE, encoding="utf-8", check=True).stdout.strip()

  for arg in sys.argv[2:]:
    index = int(arg)
    print(password[index-1])
