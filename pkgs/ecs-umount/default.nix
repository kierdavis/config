{ stdenv, writeScriptBin }:

writeScriptBin "ecs-umount" ''
  #!${stdenv.shell}
  sudo umount /mnt/ecs
''
