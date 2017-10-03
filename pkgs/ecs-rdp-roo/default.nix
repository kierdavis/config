# SUPERSEDED BY https://remotedesktop.soton.ac.uk/



{ stdenv, writeScriptBin, freerdp }:

writeScriptBin "ecs-rdp-roo" ''
  #!${stdenv.shell}
  ${freerdp}/bin/xfreerdp /v:roo.ecs.soton.ac.uk /u:kad2g15 /w:800 /h:600
''
