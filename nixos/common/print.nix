{ config, lib, pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [
      pkgs.gutenprint
      pkgs.samsung-unified-linux-driver_4_01_17
    ];
  };

  environment.variables.PRINTER = "woodside";
}
