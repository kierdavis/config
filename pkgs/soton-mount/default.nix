{ stdenv, cifs-utils, writeShellScriptBin }:

writeShellScriptBin "soton-mount" ''
  #!${stdenv.shell}
  set -o errexit -o pipefail -o nounset
  uid=$(id --user kier)
  gid=$(id --group kier)
  mountpoint=/mnt/soton
  sudo mkdir -p $mountpoint
  sudo ${cifs-utils}/bin/mount.cifs -o username=kad2g15,uid=$uid,forceuid,gid=$gid,forcegid,actimeo=60 //filestore.soton.ac.uk/users/kad2g15 $mountpoint
''
