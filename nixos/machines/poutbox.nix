{ config, lib, pkgs, ... }:

let
  baseI3Config = ../../i3;

  extraI3Config = pkgs.writeText "extra-i3config" ''
    for_window [class="poutbox-pout"] fullscreen enable
    exec ${pkgs.pout}/bin/pout --class=poutbox-pout
  '';

  i3Config = pkgs.runCommand "i3config" {} "cat ${baseI3Config} ${extraI3Config} > $out";

in {
  imports = [
    ../common
    ../extras/platform/raspberry-pi-3.nix
  ];

  machine = {
    name = "poutbox";
    wifi = false;
    ipv6-internet = false;
    cpu = {
      cores = 1;
      intel = false;
    };
  };

  fileSystems."/" = {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };

  # XXX hack, this should be made optional
  services.syncthing.enable = lib.mkForce false;

  boot.plymouth.enable = true;

  services.xserver = {
    enable = true;
    displayManager.lightdm = {
      enable = true;
      autoLogin = {
        enable = true;
        user = "kier";
      };
    };
    windowManager = {
      default = "i3";
      i3 = {
        enable = true;
        configFile = i3Config;
      };
    };
  };
  environment.systemPackages = with pkgs; [
    gnome3.dconf
    pout
  ];
}
