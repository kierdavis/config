{ fetchzip, qtbase, qtmultimedia, qttools, qtxmlpatterns, stdenv, which }:

stdenv.mkDerivation rec {
  pname = "klayout";
  version = "0.25.8";
  src = fetchzip {
    url = "https://www.klayout.org/downloads/source/klayout-${version}.tar.bz2";
    sha256 = "1vk05ymbbfxwn9mp2drd1wh8cszqh6f0arxc2hk3q52ijb91jdwz";
  };
  buildInputs = [ qtbase qtmultimedia qttools qtxmlpatterns ];
  nativeBuildInputs = [ which ];
  postPatch = ''
    patchShebangs .
  '';
  buildPhase = ''
    runHook preBuild
    ./build.sh -qt5 -expert -option -j$NIX_BUILD_CORES -bin $out/lib
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mv $out/lib/klayout $out/bin/klayout
    chmod +x $out/bin/klayout
    runHook postInstall
  '';
  CXXFLAGS = [ "-Wno-error=format-security" ];
}
