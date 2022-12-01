{ config, pkgs, lib, ... }:

with lib;

{
  #options.skaia = mkOption {
  #  type = types.anything;
  #};
  #config.skaia =
  #  let
  #    jsonFile = pkgs.runCommand "skaia-cue.json" {} ''
  #      for i in ${../../skaia/cue}/*.cue ${../../secret/skaia/cue}/*.cue; do
  #        ln -sf $i
  #      done
  #      ${pkgs.cue}/bin/cue export --out=json > $out
  #    '';
  #  in builtins.fromJSON (builtins.readFile jsonFile);
}
