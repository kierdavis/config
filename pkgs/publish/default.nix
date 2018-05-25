{ stdenv, writeShellScriptBin, openssh }:

writeShellScriptBin "publish" ''
  #!${stdenv.shell}
  set -eu
  src="$1"
  basename="$(basename "$src")"
  dest="kier@dl.kierdavis.com:/var/www/dl.kierdavis.com/www/htdocs/$basename"
  ${openssh}/bin/scp -q "$src" "$dest"
  echo "http://dl.kierdavis.com/$basename"
''
