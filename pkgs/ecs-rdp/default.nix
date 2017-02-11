{ stdenv, writeScriptBin, freerdp }:

writeScriptBin "ecs-rdp" ''
  #!${stdenv.shell}
  ${freerdp}/bin/xfreerdp /v:localhost /u:kad2g15 /w:1916 /h:1045
''
