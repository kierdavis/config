{ fetchurl, gtk2, mono, stdenv }:

stdenv.mkDerivation rec {
  name = "repetier-host-${version}";
  version = "2.1.2";

  src = fetchurl {
    url = "http://download.repetier.com/files/host/linux/repetierHostLinux_2_1_2.tgz";
    sha256 = "14w4k4q2k9j3k9qajlm2rhfa5yxf5ih465gl5csg22qd5frzlrp8";
  };

  buildPhase = ''
    runHook preBuild

    frontend=$NIX_BUILD_TOP/repetier-host
    set_baudrate=$NIX_BUILD_TOP/repetier-set-baudrate
    instdir=$out/lib/repetier-host

    echo "#!${stdenv.shell}" > $frontend
    echo "cd $instdir" >> $frontend
    echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${gtk2}/lib' >> $frontend
    echo "${mono}/bin/mono $instdir/RepetierHost.exe -home $instdir" >> $frontend

    g++ -O2 SetBaudrate.cpp -o $set_baudrate

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -D -m 0755 $frontend $out/bin/repetier-host
    install -D -m 0755 $set_baudrate $out/bin/repetier-set-baudrate
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

