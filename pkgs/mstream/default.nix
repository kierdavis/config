{ stdenv, python2, utillinux, runCommand, writeTextFile, fetchurl, fetchgit, nodejs }:

let
  comp = import ./composition.nix {
    pkgs = {
      inherit stdenv python2 utillinux runCommand writeTextFile fetchurl fetchgit;
    };
    inherit nodejs;
  };
in comp.mstream
