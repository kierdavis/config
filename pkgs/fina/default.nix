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
  version = "0.2.0";
  src = fetchCrate {
    inherit crateName version;
    # sha256 = lib.fakeSha256;
    sha256 = "1n9lk0f3av68c4cdlpmvrajn0k4wjh5fw50x8qah5mb0d2hil34m";
  };
  crate = (import ./Cargo.nix {
    inherit buildRustCrate defaultCrateOverrides lib stdenv;
    inherit src;
    nixpkgs = null;
    pkgs = { inherit defaultCrateOverrides fetchurl runCommand; };
  }).rootCrate.build;
in crate // { inherit src; }
