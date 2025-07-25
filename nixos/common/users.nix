{ config, lib, pkgs, ... }:

{
  # Force live user info to match what's declared in this file.
  users.mutableUsers = false;

  users.users.root = {
    # hashedPassword defined in config-secret#nixosModules.common
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
  };

  users.groups.kier = {
    gid = 1001;
  };
  users.users.kier = {
    createHome = false; # so that other users can read ~kier/config/nixpkgs
    description = "Kier Davis";
    extraGroups = [
      "audio"           # Permission to use audio devices e.g. /dev/snd/...
      "dialout"         # Permission to use USB serial devices (e.g. /dev/ttyACM0)
      "networkmanager"  # Permission to control NetworkManager
      "tty"             # Permission to operate any tty
      "wheel"           # Permission to 'sudo' as root
      "video"           # Permission to access video devices (including hardware acceleration of video processing)
    ];
    group = "kier";
    # hashedPassword defined in config-secret#nixosModules.common
    home = "/home/kier";
    isNormalUser = true;
    name = "kier";
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
    uid = 1001;
    useDefaultShell = true;
  };

  # Allow access to USB devices without requiring root permissions
  services.udev.extraRules = ''
    # SR V4 power board
    SUBSYSTEM=="usb", ATTR{idVendor}=="1bda", ATTR{idProduct}=="0010", GROUP="dialout", MODE="0666"
    # SR V4 servo board
    SUBSYSTEM=="usb", ATTR{idVendor}=="1bda", ATTR{idProduct}=="0011", GROUP="dialout", MODE="0666"
    # Altera "USB Blaster" JTAG cable
    SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0666"
    # Teensy
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", GROUP="dialout", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", GROUP="dialout", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", GROUP="dialout", MODE="0666"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="013*", GROUP="dialout", MODE="0666"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1fc9", ATTRS{idProduct}=="013*", GROUP="dialout", MODE="0666"
  '';

  nix.settings.trusted-users = [ "root" "kier" ];

  # sudo
  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  # Ensure systemd user bus is started if you su to another user.
  security.pam.services.su.startSession = true;
}
