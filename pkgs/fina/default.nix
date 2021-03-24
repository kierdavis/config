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
  version = "0.3.0";
  src = fetchCrate {
    inherit crateName version;
    sha256 = "10q70wiqbrwj72rz1pwlclwsn3cmwqsayprli2dnmda5mqllvx15";
  };
  crate = (import ./Cargo.nix {
    inherit buildRustCrate defaultCrateOverrides lib stdenv;
    inherit src;
    nixpkgs = null;
    pkgs = { inherit defaultCrateOverrides fetchurl runCommand; };
  }).rootCrate.build;
in crate // { inherit src; }
