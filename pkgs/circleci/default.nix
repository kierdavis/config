{ bash, docker, fetchurl, makeWrapper, stdenv }:

stdenv.mkDerivation {
  name = "circleci";

  src = fetchurl {
    url = "https://circle-downloads.s3.amazonaws.com/releases/build_agent_wrapper/circleci";
    sha256 = "12q0ymnzzz4pi79zy3wblbrxkd0dg2s84z6ysm4mvqs6hhs7m6qh";
    executable = true;
  };

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
