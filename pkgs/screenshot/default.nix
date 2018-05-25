{ stdenv, writeShellScriptBin, imagemagick, eog }:

writeShellScriptBin "screenshot" ''
  #!${stdenv.shell}
  set -eu
  dir=/tmp/screenshots
  mkdir -p "$dir"
  now=`date +'%Y-%m-%d_%H:%M:%S'`
  filename="$dir/$now.png"
  ${imagemagick}/bin/import "$filename"
  ${eog}/bin/eog "$filename" &
''
