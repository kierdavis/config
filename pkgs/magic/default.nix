{ fetchurl, libX11, m4, readline, stdenv, tcl, tcsh, tk }:

stdenv.mkDerivation rec {
  name = "magic";
  version = "8.1.218";

  src = fetchurl {
    url = "http://opencircuitdesign.com/magic/archive/magic-${version}.tgz";
    sha256 = "0ss5fqdzvxlj4ksrp545ijh4rknbpb3m3w61iwp1x87fx2fc9lrx";
  };
  patches = [
    ./fix-insecure-printf.patch
    ./propagate-configure-cflags.patch
  ];
  postPatch = ''
    for file in $(find scripts -type f); do
      sed -i "s,/bin/csh,${tcsh}/bin/tcsh,g" $file
    done
  '';

  nativeBuildInputs = [ m4 ];
  buildInputs = [ libX11.dev readline.dev tcl tk ];
  configureFlags = [
    "--with-tcl=${tcl}/lib"
    "--with-tk=${tk}/lib"
  ];

  # Magic is not compiled with optimisation by default.
  CFLAGS = [ "-O2" ];
}
