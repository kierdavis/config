{ stdenv, writeScriptBin }:

writeScriptBin "soton-umount" ''
  #!${stdenv.shell}
  sudo umount /mnt/soton
''
