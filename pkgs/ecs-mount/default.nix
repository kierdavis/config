{ stdenv, cifs-utils, writeScriptBin }:

writeScriptBin "ecs-mount" ''
  #!${stdenv.shell}
  uid=$(id --user kier)
  gid=$(id --group kier)
  sudo ${cifs-utils}/bin/mount.cifs -o username=kad2g15,uid=$uid,forceuid,gid=$gid,forcegid,actimeo=60 //ugsamba.ecs.soton.ac.uk/kad2g15 /mnt/ecs
''
