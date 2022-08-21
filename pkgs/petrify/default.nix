{ fetchurl, lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "petrify";
  version = "5.2";
  src = fetchurl {
    url = "https://www.cs.upc.edu/~jordicf/petrify/distrib/petrify-${version}-linux.tar.gz";
    hash = "sha256:1f9hdd6v46pw8r8y9rgs177zcqy1drq6y60dgh64iiw18n2gzljc";
  };
  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    install -D -m 0755 -d $out/bin
    install -D -m 0755 bin/* -t $out/bin
    install -D -m 0755 -d $out/lib
    install -D -m 0644 lib/* -t $out/lib
    install -D -m 0755 -d $out/share/doc/petrify
    install -D -m 0644 doc/* -t $out/share/doc/petrify
    install -D -m 0755 -d $out/share/man/man1
    install -D -m 0644 man/man1/* -t $out/share/man/man1
  '';
}
