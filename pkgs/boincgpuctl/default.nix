{ stdenv, writeShellScriptBin, boinc }:

writeShellScriptBin "boincgpuctl" ''
#!/bin/sh

cd /var/lib/boinc

if [ "$1" = "on" ]; then
  newstate="always"
elif [ "$1" = "off" ]; then
  newstate="never"
elif [ "$1" = "toggle" ]; then
  gpuoff=$(${boinc}/bin/boinccmd --get_cc_status 2>/dev/null | grep 'GPU status' -A 2 | grep 'current mode: never')
  if [ -n "$gpuoff" ]; then
    newstate="always"
  else
    newstate="never"
  fi
else
  echo "usage: $0 on|off|toggle"
  exit 2
fi

echo "setting GPU computation mode to: $newstate"
${boinc}/bin/boinccmd --set_gpu_mode $newstate
''
