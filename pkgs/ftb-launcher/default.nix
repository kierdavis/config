{ stdenv, fetchurl
, jre, libX11, libXext, libXcursor, libXrandr, libXxf86vm
, mesa, openal }:

with stdenv.lib;

stdenv.mkDerivation {
  name = "ftb-launcher-2";

  src = fetchurl {
    url = "http://ftb.cursecdn.com/FTB2/launcher/FTB_Launcher.jar";
    sha256 = "1wqpwqpfs646xarslxn81b62dj95h6ynz7p9379y7i68yzqhwp5c";
  };

  phases = "installPhase";

  installPhase = ''
    set -x
    mkdir -pv $out/bin
    cp -v $src $out/ftb-launcher.jar

    cat > $out/bin/ftb-launcher << EOF
    #!${stdenv.shell}

    export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${makeLibraryPath [ libX11 libXext libXcursor libXrandr libXxf86vm mesa openal ]}
    ${jre}/bin/java -jar $out/ftb-launcher.jar
    EOF

    chmod +x $out/bin/ftb-launcher
  '';

  meta = {
    description = "A sandbox-building game";
    homepage = http://www.minecraft.net;
    maintainers = with stdenv.lib.maintainers; [ page ryantm ];
    license = licenses.unfree;
  };
}
