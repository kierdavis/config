{ bash, docker, fetchurl, makeWrapper, stdenv }:

stdenv.mkDerivation {
  name = "circleci";

  src = fetchurl {
    url = "https://circle-downloads.s3.amazonaws.com/releases/build_agent_wrapper/circleci";
    sha256 = "1mhy6iqadcfncwpfna9k5hsrka07i03v6ipv32vmbkbbb9y8zvnq";
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
