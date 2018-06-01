{ stdenv, writeShellScriptBin, i3lock }:

writeShellScriptBin "lock" ''
  #!${stdenv.shell}
  bg=/home/kier/.background-image
  flags=""
  if [ -f "$bg" ]; then
    flags="$flags -i $bg"
  fi
  ${i3lock}/bin/i3lock $flags
''
