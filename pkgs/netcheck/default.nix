args@{ lib, buildPlatform, buildRustCrate, fetchgit }:
(import ./Cargo.nix args).netcheck {}
