{ stdenv, fetchurl, librdf_raptor2, librdf_rasqal, librdf_redland, pkgconfig }:

stdenv.mkDerivation rec {
  version = "0.5.4";
  name = "redstore-${version}";
  src = fetchurl {
    url = "http://www.aelius.com/njh/redstore/redstore-${version}.tar.gz";
    sha256 = "0hc1fjfbfvggl72zqx27v4wy84f5m7bp4dnwd8g41aw8lgynbgaq";
  };
  patches = [ ./redstore.patch ];
  buildInputs = [
    librdf_raptor2
    librdf_rasqal
    librdf_redland
    pkgconfig
  ];
}
