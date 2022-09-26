{ config, pkgs, lib, ... }:

with lib;

{
  options.hist5 = mkOption {
    type = types.anything;
  };
  config.hist5 =
    let
      jsonFile = pkgs.runCommand "hist5-cue.json" {} ''
        for i in ${../../hist5/cue}/*.cue ${../../secret/hist5/cue}/*.cue; do
          ln -sf $i
        done
        ${pkgs.cue}/bin/cue export --out=json > $out
      '';
    in builtins.fromJSON (builtins.readFile jsonFile);
}
