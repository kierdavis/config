{ stdenv, writeScriptBin, cryptsetup }:

writeScriptBin "mountext" ''
  #!${stdenv.shell}
  set -eu
  sudo ${cryptsetup}/bin/cryptsetup --type luks open /dev/disk/by-id/usb-TOSHIBA_External_USB_3.0_20151209015531-0:0-part1 ext
  sudo mount -t ext4 /dev/mapper/ext /mnt/ext
''
