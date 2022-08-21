{ coreutils, fetchurl, glib, gmp, graphviz, gtk2, guile, pkg-config, stdenv }:

stdenv.mkDerivation rec {
  pname = "balsa";
  version = "4.0";
  src = fetchurl {
    url = "http://apt.cs.manchester.ac.uk/ftp/pub/apt/balsa/${version}/balsa-${version}.tar.gz";
    hash = "sha256-ssPMpy2nfJ59LJf+ad3HJ1Rmkw1OaxnCwENW8XewDSo=";
  };
  patches = [
    ./fix-libtool-compat.patch
    ./fix-libc-compat.patch
    ./fix-guile-compat.patch
    ./nix-store-paths.patch
  ];
  inherit coreutils graphviz;
  postPatch = ''
    substituteInPlace share/scheme/breeze2ps.scm \
      --subst-var coreutils \
      --subst-var graphviz
  '';
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ glib gmp gtk2 guile ];
  enableParallelBuilding = false;
  NIX_CFLAGS_COMPILE = "-w";
}
