{ appimage-run, fetchurl, writeShellScriptBin }:

let
  src = fetchurl {
    url = "https://github.com/ifedapoolarewaju/igdm/releases/download/v2.6.5/IGdm-2.6.5-x86_64.AppImage";
    sha256 = "1hc5v4sv28p8awj1584x1bqrd5ln20kqd4q6jis3bfy36gkwd4sy";
    executable = true;
  };

in writeShellScriptBin "igdm" ''
  exec ${appimage-run}/bin/appimage-run ${src} "$@"
''

