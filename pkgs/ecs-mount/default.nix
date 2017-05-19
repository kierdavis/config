{ stdenv, writeScriptBin }:

writeScriptBin "ecs-mount" ''
  #!${stdenv.shell}
  uid=$(id --user kier)
  gid=$(id --group kier)
  sudo mount -t cifs -o username=kad2g15 -o uid=$uid -o forceuid -o gid=$gid -o forcegid -o actimeo=60 //ugsamba.ecs.soton.ac.uk/kad2g15 /mnt/ecs
''
