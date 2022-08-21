{ fetchFromGitHub, stdenv }:

stdenv.mkDerivation {
  name = "espresso";
  src = fetchFromGitHub {
    owner = "classabbyamp";
    repo = "espresso-logic";
    rev = "v1.1.1";
    hash = "sha256-qgq+9Z3zYLXakJ0CQtF6eF8tL26CB6UTto/L3ZuqRdk=";
  };
  buildPhase = ''
    make -C espresso-src
  '';
  installPhase = ''
    install -D -m 0755 bin/espresso -t $out/bin
    install -D -m 0644 man/* -t $out/share/man
  '';
}
