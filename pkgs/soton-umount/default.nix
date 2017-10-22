{ stdenv, writeScriptBin }:

writeScriptBin "soton-umount" ''
  #!${stdenv.shell}
  mountpoint=/mnt/soton
  sudo umount $mountpoint
  sudo rmdir $mountpoint
''
