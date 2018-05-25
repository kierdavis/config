{ stdenv, writeShellScriptBin }:

writeShellScriptBin "soton-umount" ''
  #!${stdenv.shell}
  set -o errexit -o pipefail -o nounset
  mountpoint=/mnt/soton
  sudo umount $mountpoint
  sudo rmdir $mountpoint
''
