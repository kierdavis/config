# http://www.romilly.co.uk/hartmaster.htm

{ fetchurl
, lib
, mysql
, ncurses
, stdenv
, withMysql ? false
}:

with lib;

stdenv.mkDerivation rec {
  name = "hartmaster-${version}";
  version = "150720";

  src = fetchurl {
    url = "http://www.romilly.co.uk/hart_master_${version}.tgz";
    sha256 = "0413yamq5w0rwgp1aixmbl5jadg4xk2a9bx23bnhh8rrkkkc5q84";
  };

  buildInputs = [ mysql ncurses ];

  phases = "unpackPhase buildPhase installPhase fixupPhase distPhase";
  buildPhase = ''
    runHook preBuild

    pushd hart_master
    make ${if withMysql then "master_full" else "master_tf"}
    popd

    pushd hart_tests
    make
    popd

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    install -D -m 0755 hart_master/master $out/bin/hartmaster
    install -D -m 0755 hart_tests/hartcmdline $out/bin/hartcmdline
    #install -D -m 0755 harttooldb/harttooldb $out/bin/harttooldb
    runHook postInstall
  '';
}
