{ fetchFromGitHub
, fetchgit
, fetchurl
, lib
, nix-gitignore
, node2nix
, nodejs
, python2
, python3
, runCommand
, stdenv
, util-linux
, writeShellScript
, writeShellScriptBin
, writeTextFile
}:

let stuff = rec {
  port = 8080;
  modelVersion = "mini";
  src = stdenv.mkDerivation {
    name = "dalle-playground-src";
    src = fetchFromGitHub {
      owner = "saharmor";
      repo = "dalle-playground";
      rev = "a7ffef51c466795be04b8a2c66c06831a2e8f4ce";
      hash = "sha256:1rbs136gjz2igakfqgpbgcnrqxskv181w3v1zadj53lbns93yahp";
    };
    patches = [ ./fix-missing-babel-config.patch ];
    installPhase = ''
      cp -r . $out
    '';
    doFixup = false;
  };
  pythonUniverse = python3.override {
    packageOverrides = self: super: {
      dalle-mini = self.buildPythonPackage rec {
        pname = "dalle-mini";
        version = "8c1c8849ef931d5de378f67c2f895aff7bb5e21c";
        src = fetchFromGitHub {
          owner = "borisdayma";
          repo = pname;
          rev = version;
          hash = "sha256:1qan6zbsydsh78k5lfr7d3m99avn0549r48ii83j58mw2dghf3yi";
        };
        propagatedBuildInputs = with self; [
          einops
          emoji
          flax
          ftfy
          jax
          jaxlib
          pillow
          transformers
          unidecode
          wandb
        ];
      };
      jaxlib = super.jaxlib.override { cudaSupport = true; };  # Performance would be unusably bad without a good GPU.
      vqgan-jax = self.buildPythonPackage rec {
        pname = "vqgan-jax";
        version = "1be20eee476e5d35c30e4ec3ed12222018af8ce4";
        src = fetchFromGitHub {
          owner = "patil-suraj";
          repo = pname;
          rev = version;
          hash = "sha256:1xxhalklhg5ssa59plrki2naapq0wrqg2dz4d8h4pla4g80s361r";
        };
        propagatedBuildInputs = with self; [
          flax
          jax
          jaxlib
          transformers
        ];
        doCheck = false;  # no tests to run
      };
    };
  };
  backendPythonEnv = pythonUniverse.withPackages (pyPkgs: with pyPkgs; [
    dalle-mini
    flask
    flask-cors
    flax
    jax
    jaxlib
    numpy
    pillow
    vqgan-jax
    wandb
  ]);
  frontendNode2Nix = runCommand "node2nix" {} ''
    mkdir -p $out
    cd $out
    ${node2nix}/bin/node2nix --input ${src}/interface/package.json --lock ${src}/interface/package-lock.json
  '';
  frontendDeps = (import frontendNode2Nix {
    inherit nodejs;
    pkgs = { inherit fetchgit fetchurl lib nix-gitignore python2 runCommand stdenv util-linux writeShellScript writeTextFile; };
  }).nodeDependencies;
  dalle-playground = stdenv.mkDerivation {
    name = "dalle-playground";
    inherit src;
    installPhase = ''
      mkdir -p $out/{bin,lib/dalle-playground/{backend,frontend}}
      ln -s $src/backend/* -t $out/lib/dalle-playground/backend
      ln -s $src/interface/{*,.babelrc} -t $out/lib/dalle-playground/frontend
      ln -s ${frontendDeps}/lib/node_modules $out/lib/dalle-playground/frontend/node_modules

      cat > $out/bin/dalle-playground-backend <<EOF
      #!${stdenv.shell}
      set -o errexit -o nounset -o pipefail
      # wandb needs writable working directory
      cd $(mktemp -d)
      ln -s $out/lib/dalle-playground/backend/* -t .
      exec ${backendPythonEnv}/bin/python app.py --port ${builtins.toString port} --model_version ${modelVersion}
      EOF

      cat > $out/bin/dalle-playground-frontend <<EOF
      #!${stdenv.shell}
      set -o errexit -o nounset -o pipefail
      cd $out/lib/dalle-playground/frontend
      export PATH=${frontendDeps}/bin:${nodejs}/bin:\$PATH
      exec react-scripts start
      EOF

      chmod +x $out/bin/*
    '';
  };
}; in stuff
