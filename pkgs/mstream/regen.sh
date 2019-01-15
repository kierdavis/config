#!/usr/bin/env nix-shell
#!nix-shell -i sh -p nodePackages.node2nix
node2nix --input packages.json --composition composition.nix
sed -r -i 's@(nodeEnv\.buildNodePackage)@import ./override-build-node-package.nix \1@' node-packages.nix
