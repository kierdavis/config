{ config, lib, pkgs, ... }:

let
  passwords = import ../../secret/passwords.nix;

in {
  # Force live user info to match what's declared in this file.
  users.mutableUsers = false;

  users.users.root = {
    # TODO: remove this
    hashedPassword = passwords.user.root;
  };

  users.users.kier = {
    createHome = true;
    description = "Kier Davis";
    extraGroups = [
      "audio"           # Permission to use audio devices e.g. /dev/snd/...
      "dialout"         # Permission to use USB serial devices (e.g. /dev/ttyACM0)
      "docker"          # Permission to communicate with the Docker daemon
      "networkmanager"  # Permission to control NetworkManager
      "wheel"           # Permission to use 'sudo'
      "video"           # Permission to access video devices (including hardware acceleration of video processing)
    ];
    hashedPassword = passwords.user.kier;
    home = "/home/kier";
    isNormalUser = true;
    name = "kier";
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
    uid = 1001;
    useDefaultShell = true;
  };

  users.users.nixremotebuild = {
    description = "Nix remote build user";
    isNormalUser = false;
    isSystemUser = true;
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
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
  '';

  nix.trustedUsers = [ "root" "kier" "nixremotebuild" ];
}
