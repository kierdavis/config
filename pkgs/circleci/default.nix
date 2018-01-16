{ bash, docker, fetchurl, makeWrapper, stdenv }:

stdenv.mkDerivation {
  name = "circleci";

  src = ./circleci;

  buildInputs = [ makeWrapper ];

  phases = [ "installPhase" ];

  installPhase = ''
    install -D -m 0755 $src $out/bin/circleci
    wrapProgram $out/bin/circleci \
     --argv0 circleci \
     --suffix PATH : ${bash}/bin:${docker}/bin
  '';

  preferLocalBuild = true;
}
