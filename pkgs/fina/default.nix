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
  version = "0.2.1";
  src = fetchCrate {
    inherit crateName version;
    sha256 = "16cmxv97jm7fv8676i2rs9nvzh3srrwzs3fgyivhinamvdwfhvah";
  };
  crate = (import ./Cargo.nix {
    inherit buildRustCrate defaultCrateOverrides lib stdenv;
    inherit src;
    nixpkgs = null;
    pkgs = { inherit defaultCrateOverrides fetchurl runCommand; };
  }).rootCrate.build;
in crate // { inherit src; }
