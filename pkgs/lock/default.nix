{ stdenv, writeScriptBin, i3lock }:

writeScriptBin "lock" ''
  #!${stdenv.shell}
  bg=/home/kier/.background-image
  flags=""
  if [ -f "$bg" ]; then
    flags="$flags -i $bg"
  fi
  ${i3lock}/bin/i3lock $flags
''
