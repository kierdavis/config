{ stdenv, writeScriptBin, imagemagick, eog }:

writeScriptBin "screenshot" ''
  #!${stdenv.shell}
  set -eu
  mkdir -p /home/kier/screenshots
  now=`date +'%Y-%m-%d_%H:%M:%S'`
  filename="/home/kier/screenshots/$now.png"
  ${imagemagick}/bin/import "$filename"
  ${eog}/bin/eog "$filename" &
''
