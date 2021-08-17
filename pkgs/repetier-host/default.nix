{ fetchurl, gtk2, mono, stdenv }:

stdenv.mkDerivation rec {
  name = "repetier-host-${version}";
  version = "2.2.2";

  src = fetchurl {
    url = "https://download3.repetier.com/files/host/linux/repetierHostLinux_2_2_2.tgz";
    hash = "sha256:10n3liwww7alcxxavkr12ps8s549rix5qykqgic1skrqah14nrg5";
  };

  buildPhase = ''
    runHook preBuild

    frontend=$NIX_BUILD_TOP/repetier-host
    set_baudrate=$NIX_BUILD_TOP/SetBaudrate
    instdir=$out/lib/repetier-host

    echo "#!${stdenv.shell}" > $frontend
    echo "cd $instdir" >> $frontend
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${gtk2}/lib' >> $frontend
    echo "${mono}/bin/mono $instdir/RepetierHost.exe -home $instdir" >> $frontend

    # This program breaks if optimisations are enabled!!!
    g++ -O0 SetBaudrate.cpp -o $set_baudrate

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D -m 0755 $frontend $out/bin/repetier-host
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
    # TODO: createDesktopIcon.sh Repetier-Host.desktop Repetier-Host.menu RepetierHostMimeTypes.xml repetier-RepetierHost.desktop
    runHook postInstall
  '';
}

