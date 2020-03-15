{ bundlerEnv, fetchFromGitHub, ripgrep, stdenv, writeShellScriptBin }:

let
  src = fetchFromGitHub {
    owner = "jethrogb";
    repo = "rustc-commit-db";
    rev = "cc7324166062352271df573e5ccbf4e51f23254f";
    sha256 = "12mfc7z3kflqq91n5945p91r5whqm2y9jayfgz1a8l623gq04xks";
  };

  rubyDeps = bundlerEnv {
    name = "rustc-commit-db-env";
    gemdir = ./rubydeps;
  };

  unwrapped = stdenv.mkDerivation {
    name = "rustc-commit-db-unwrapped";
    inherit src;
    buildInputs = [ rubyDeps.wrappedRuby ];
    phases = [ "unpackPhase" "patchPhase" "installPhase" "fixupPhase" ];
    patchPhase = ''
      sed -i '/Dir.chdir(File.dirname(__FILE__))/d' commit-db.rb
    '';
    installPhase = ''
      install -D -m 0755 commit-db.rb $out/bin/rustc-commit-db

      mkdir -p $out/share/rustc-commit-db
      cp -r bbot_json_cache commit_cache dist_toml_cache fixups $out/share/rustc-commit-db
    '';
  };

in writeShellScriptBin "rustc-commit-db" ''
  new_args=()
  directory=${unwrapped}/share/rustc-commit-db
  while [[ $# -ne 0 ]]; do
    if [[ "$1" = "--directory" ]]; then
      directory="$2"
      shift 2
    else
      new_args+=("$1")
      shift
    fi
  done
  cd "$directory"
  export PATH=$PATH:${ripgrep}/bin
  export AWS_ACCESS_KEY_ID=dummy
  export AWS_SECRET_ACCESS_KEY=dummy
  exec ${unwrapped}/bin/rustc-commit-db "''${new_args[@]}"
''
