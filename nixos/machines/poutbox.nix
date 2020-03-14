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
  fileSystems."/boot" = {
    device = "/dev/mmcblk0p1";
    fsType = "vfat";
  };

  # XXX hack, this should be made optional
  services.syncthing.enable = lib.mkForce false;

  boot.plymouth.enable = true;

  # When console login prompt is reached, automatically log in and start sway.
  services.mingetty.autologinUser = "kier";
  environment.etc."profile".text = ''
    if [[ "$USER" = "kier" && "$(tty)" = "/dev/tty1" ]]; then
      while true; do
        sway --config ${i3Config}
        echo "Restarting sway in 5 seconds..."
        sleep 5
      done
    fi
  '';
  programs.sway = {
    enable = true;
  };
  environment.systemPackages = with pkgs; [
    pout
  ];
}
