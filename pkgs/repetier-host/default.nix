{ fetchurl, gtk2, makeWrapper, mono, stdenv }:

stdenv.mkDerivation rec {
  name = "repetier-host-${version}";
  version = "2.2.2";

  src = fetchurl {
    url = "https://download3.repetier.com/files/host/linux/repetierHostLinux_2_2_2.tgz";
    hash = "sha256:10n3liwww7alcxxavkr12ps8s549rix5qykqgic1skrqah14nrg5";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    runHook preBuild

    set_baudrate=$NIX_BUILD_TOP/SetBaudrate
    instdir=$out/libexec/repetier-host

    # This program breaks if optimisations are enabled!!!
    g++ -O0 -w SetBaudrate.cpp -o $set_baudrate

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D -m 0755 $set_baudrate $instdir/SetBaudrate
    for file in *.{application,dll,exe,exe.config,exe.manifest}; do
      install -D -m 0644 $file $instdir/$file
    done
    for dir in data plugins; do
      cp -R $dir $instdir/$dir
    done
    for file in changelog.txt README.txt Repetier-Host-licence.txt; do
      install -D -m 0644 $file $out/share/doc/repetier-host/$file
    done
    install -D -m 0644 repetier-logo.png $out/share/icons/hicolor/128x128/apps/repetier-host.png
    # TODO: createDesktopIcon.sh Repetier-Host.desktop Repetier-Host.menu RepetierHostMimeTypes.xml repetier-RepetierHost.desktop
    install -D -m 0755 -d $out/bin
    makeWrapper ${mono}/bin/mono $out/bin/repetier-host \
      --run "cd $instdir" \
      --prefix LD_LIBRARY_PATH : ${gtk2}/lib \
      --add-flags "$instdir/RepetierHost.exe -home $instdir"
    runHook postInstall
  '';
}

