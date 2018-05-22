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
      "dialout"         # Permission to use USB serial devices (e.g. /dev/ttyACM0)
      "docker"          # Permission to communicate with the Docker daemon
      "duplicity"       # Permission to use the central duplicity archive directory
      "networkmanager"  # Permission to control NetworkManager
      "wheel"           # Permission to use 'sudo'
      "video"           # Permission to access video devices (including hardware acceleration of video processing)
    ];
    hashedPassword = passwords.user.kier;
    home = "/home/kier";
    isNormalUser = true;
    name = "kier";
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
    useDefaultShell = true;
  };

  # This user owns the duplicity archive directory.
  users.groups.duplicity = {};
  users.users.duplicity = {
    createHome = true;
    description = "Duplicity backup";
    group = "duplicity";
    home = "/var/lib/duplicity";
    isSystemUser = true;
  };
}
