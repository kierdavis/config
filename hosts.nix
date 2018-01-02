{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib;

  vpnHosts = import ./campanella/vpn-hosts.nix;
  stringifyHost = name: addr: "${addr} ${name}\n";

in rec {
  hosts = vpnHosts // {
    beagle2 = "176.9.121.81";
    soton = "86.5.103.14";
  };

  fileContents = lib.concatStrings (lib.mapAttrsToList stringifyHost hosts);
  file = pkgs.writeFile "hosts" fileContents;
}
