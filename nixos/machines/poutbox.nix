{ config, lib, pkgs, ... }:

let
  baseI3Config = ../../i3;

  extraI3Config = pkgs.writeText "extra-i3config" ''
    for_window [class="poutbox-pout"] fullscreen enable
    exec ${pkgs.pout}/bin/pout --class=poutbox-pout
  '';

  i3Config = pkgs.runCommand "i3config" {} "cat ${baseI3Config} ${extraI3Config} > $out";

  swayTTY = "tty1";

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

  services.mingetty.autologinUser = "kier";
  systemd.defaultUnit = "graphical.target";
  systemd.services.sway = {
    description = "sway window manager";
    wantedBy = [ "graphical.target" ];
    requires = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    conflicts = [ "getty@${swayTTY}.service" ];
    preStart = "/run/current-system/sw/bin/systemctl --user start dbus";
    script = "/run/current-system/sw/bin/sway --config ${i3Config} || sleep infinity";
    serviceConfig = {
      StandardInput = "tty-force";
      TTYPath = "/dev/${swayTTY}";
      User = "kier";
      Group = "users";
      PAMName = "graphical";
    };
  };
  programs.sway.enable = true;
  security.pam.services.graphical = {
    startSession = true;
  };
}
