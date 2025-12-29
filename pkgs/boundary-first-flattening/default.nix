{ blas
, cmake
, fetchFromGitHub
, glib
, lib
, libglvnd
, libX11
, libXcursor
, libXi
, libXinerama
, libXrandr
, libXxf86vm
, makeWrapper
, stdenv
, suitesparse
, zenity
}:

let
  rev = "6924b2fd22fc26cb25d532a8130a0b44454dbeb0";
in

stdenv.mkDerivation rec {
  pname = "boundary-first-flattening";
  version = builtins.substring 0 8 rev;
  outputs = [ "out" "dev" "lib" ];
  src = fetchFromGitHub {
    owner = "GeometryCollective";
    repo = pname;
    inherit rev;
    fetchSubmodules = true;
    hash = "sha256-snWsx5wsjvBSSbrsBfYWADFszkfbqRgbZbdS3r9IVzw=";
  };
  patches = [ ./cstdint.patch ];
  nativeBuildInputs = [ cmake makeWrapper ];
  buildInputs = [ blas libglvnd libX11 libXcursor libXi libXinerama libXrandr libXxf86vm suitesparse ];
  installPhase = ''
    install -D -m 0755 bff-command-line bff-viewer -t $out/bin
    install -D -m 0644 libbff.a -t $lib/lib
    install -D -m 0755 deps/nanogui/libnanogui.so -t $lib/lib
    install -D -m 0755 -d $dev/include
    cp -r ../include/bff $dev/include/bff

    rm $lib/lib/cmake/glm/glmConfig.cmake
    rmdir $lib/lib/cmake/glm $lib/lib/cmake

    wrapProgram $out/bin/bff-viewer --prefix PATH : "$viewerBinPath"
  '';
  viewerBinPath = lib.makeBinPath [ glib zenity ];
  cmakeFlags = ["-DCMAKE_SKIP_BUILD_RPATH=ON" "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"];
  enableParallelBuilding = true;
}
