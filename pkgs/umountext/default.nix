{ stdenv, writeScriptBin, cryptsetup }:

writeScriptBin "umountext" ''
  #!${stdenv.shell}
  set -eu
  sudo umount /dev/mapper/ext
  sudo ${cryptsetup}/bin/cryptsetup close ext
''
