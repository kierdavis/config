{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.cups ];
  environment.variables.CUPS_SERVER = "bonito";
}
