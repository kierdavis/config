{ buildRustCrate
, defaultCrateOverrides
, fetchCrate
, fetchurl
, lib
, runCommand
, stdenv
}:

let
  crateName = "fina";
  version = "0.1.0";
  src = fetchCrate {
    inherit crateName version;
    # sha256 = lib.fakeSha256;
    sha256 = "12f2ipppfq1mlmgqban1ka4pj1rsqfv2hf5x9nvzd7j6h9s1ylx7";
  };
  crate = (import ./Cargo.nix {
    inherit buildRustCrate defaultCrateOverrides lib stdenv;
    inherit src;
    nixpkgs = null;
    pkgs = { inherit defaultCrateOverrides fetchurl runCommand; };
  }).rootCrate.build;
in crate // { inherit src; }
