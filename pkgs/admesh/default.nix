{ autoreconfHook, fetchFromGitHub, git, stdenv }:

stdenv.mkDerivation rec {
  name = "admesh-${version}";
  version = "0.98.3";

  src = fetchFromGitHub {
    owner = "admesh";
    repo = "admesh";
    rev = "v${version}";
    sha256 = "188jb1g5jyxkhlsv656m3fq0n4aj7y6nx69v0hc2j6rcfg878iqb";
  };

  nativeBuildInputs = [ autoreconfHook ];
  preBuild = ''
    touch AUTHORS ChangeLog
  '';
}
