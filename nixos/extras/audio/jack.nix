{ config, lib, pkgs, ... }:

{
  hardware.pulseaudio.enable = false;
  services.jack = {
    jackd = {
      enable = true;
      extraOptions = ["-d" "alsa"] ++ (if config.machine.jackDevice != null then ["--device" config.machine.jackDevice] else []);
    };
    alsa.enable = true;
  };

  users.users.kier.extraGroups = ["jackaudio"];

  environment.systemPackages = [ pkgs.qjackctl ];
}
