{ autoconf
, automake
, fetchFromGitHub
, fetchpatch
, json_c
, libpcap
, libtool
, pkgconfig
, stdenv
, which
}:

stdenv.mkDerivation rec {
  pname = "ndpi";
  version = "4.0";

  src = fetchFromGitHub {
    owner = "ntop";
    repo = "nDPI";
    rev = version;
    hash = "sha256:0snzvlracc6s7r2pgdn0jqcc7nxjxzcivsa579h90g5ibhhplv5x";
  };
  patches = [
    # ntopng 5.0 seems to depend on an unreleased feature of nDPI??
    (fetchpatch {
      url = https://github.com/ntop/nDPI/commit/46ebd7128fd38f3eac5289ba281f3f25bad1d899.patch;
      sha256 = "0pbdf9yd54j9jc808jh6kcmd8m9cgnpachq443mg4lhhv9wg8q1h";
    })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkgconfig
    which
  ];
  buildInputs = [
    libpcap
    json_c
  ];

  configureScript = "./autogen.sh";
  enableParallelBuilding = true;
} 
