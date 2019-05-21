#!/bin/sh

carnix_expr='
  let
    url = https://github.com/NixOS/nixpkgs/archive/507a3a9a39d772c51a76ce4598042d57f45e2ed0.tar.gz;
    pkgs = import (fetchTarball url) {};
  in pkgs.carnix
'
carnix_pkg=$(nix-build --no-out-link -E "$carnix_expr")
carnix="$carnix_pkg/bin/carnix"

$carnix --output Cargo.nix crate/Cargo.lock
