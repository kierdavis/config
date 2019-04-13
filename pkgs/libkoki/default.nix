{ doxygen
, fetchFromGitHub
, freeglut
, glib
, libGL
, libGLU
, libyaml
, opencv
, pkgconfig
, scons
, stdenv
}:

stdenv.mkDerivation rec {
  version = "0.0.1";
  name = "libkoki-${version}";
  src = fetchFromGitHub {
    owner = "srobo";
    repo = "libkoki";
    rev = "5b3c679c1f84b8fae9ab3cc5a93125dc58643a85";
    sha256 = "104gcmpk462f24qv043plarq3b6qryaswh3d35bc90w7vm0j132c";
  };
  patches = [
    ./scons-cleanup.patch
    ./scons-propagate-env-vars.patch
  ];
  nativeBuildInputs = [ doxygen pkgconfig scons ];
  buildInputs = [ glib libyaml opencv ];
  postPatch = ''
    # Fix the create-pkg-config script.
    patchShebangs .
    # Don't build the examples, since have extra dependencies and they don't get installed anyway.
    mv examples/SConscript examples/SConscript.disabled
  '';
  preBuild = ''
    export DESTDIR=$out
  '';
  buildPhase = ''
    runHook preBuild
    scons
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    scons install
    runHook postInstall
  '';
}
