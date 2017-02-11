{ stdenv, writeScriptBin, openssh }:

writeScriptBin "ecs-rdp-tunnel" ''
  #!${stdenv.shell}
  if [ "$1" = "roo" -o "$1" = "robin" ]; then
    ${openssh}/bin/ssh -o 'ServerAliveInterval 60' -L 3389:$1.ecs.soton.ac.uk:3389 kad2g15@uglogin.ecs.soton.ac.uk
  else
    echo "usage: $0 roo|robin"
    exit 2
  fi
''
