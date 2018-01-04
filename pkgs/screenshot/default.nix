{ stdenv, writeScriptBin, imagemagick, eog }:

writeScriptBin "screenshot" ''
  #!${stdenv.shell}
  set -eu
  dir=/tmp/screenshots
  mkdir -p "$dir"
  now=`date +'%Y-%m-%d_%H:%M:%S'`
  filename="dir/$now.png"
  ${imagemagick}/bin/import "$filename"
  ${eog}/bin/eog "$filename" &
''
