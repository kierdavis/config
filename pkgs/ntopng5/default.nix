{ autoconf
, automake
, curlMinimal
, expat
, fetchFromGitHub
, json_c
, libcap
, libgcrypt
, libgpgerror
, libmaxminddb
, libmysqlclient
, libpcap
, libsodium
, libtool
, ndpi4
, net-snmp
, openldap
, openssl
, pkgconfig
, readline
, rrdtool
, sqlite
, stdenv
, uglify-js
, which
, zeromq
, zstd
}:

stdenv.mkDerivation rec {
  pname = "ntopng";
  version = "5.0";

  src = fetchFromGitHub {
    owner = "ntop";
    repo = "ntopng";
    rev = version;
    hash = "sha256:0w84vwxkfpv7rbmkjk2fqm8qxk5gps7hv4qxhzlj7pjlb18i8b3c";
  };
  patches = [
    ./0001-Use-PATH-rather-than-hardcoding-locations-of-executa.patch
    ./0002-Fix-bash-syntax-error-when-building-from-a-source-ta.patch
    ./0003-Hide-errors-from-which-lookups.patch
    ./0004-Hide-C-C-compiler-warnings.patch
  ];

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkgconfig
    uglify-js
    which
  ];
  buildInputs = [
    curlMinimal
    expat
    json_c
    libcap
    libgcrypt
    libgpgerror
    libmaxminddb
    libmysqlclient
    libpcap
    libsodium
    openldap
    ndpi4
    net-snmp
    openssl
    readline
    rrdtool
    sqlite
    zeromq
    zstd
    # -lrrd_th: does nixpkgs have this? where?
    # -lnl: nixpkgs only has -lnl-3
    # -lwrap: does nixpkgs have this? where?
    # -lradcli: does nixpkgs have this? where?
  ];

  preConfigure = ''bash ./autogen.sh'';
  enableParallelBuilding = true;
}
