{ stdenv, writeShellScriptBin, freerdp }:

writeShellScriptBin "soton-rdp" ''
  #!${stdenv.shell}
  ${freerdp}/bin/xfreerdp /v:rdbroker.soton.ac.uk /gd:remotedesktopgateway.soton.ac.uk /u:kad2g15 /gu:kad2g15 /w:1840 /h:1000
''
