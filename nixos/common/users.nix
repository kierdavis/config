{ config, lib, pkgs, ... }:

let
  secrets = import ../../secret;

in {
  # Force live user info to match what's declared in this file.
  users.mutableUsers = false;

  users.users.root = {
    # TODO: remove this
    hashedPassword = secrets.user-passwords.root;
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
  };

  users.users.kier = {
    createHome = true;
    description = "Kier Davis";
    extraGroups = [
      "dialout"         # Permission to use USB serial devices (e.g. /dev/ttyACM0)
      "docker"          # Permission to communicate with the Docker daemon
      "networkmanager"  # Permission to control NetworkManager
      "wheel"           # Permission to use 'sudo'
      "video"           # Permission to access video devices (including hardware acceleration of video processing)
    ];
    hashedPassword = secrets.user-passwords.kier;
    home = "/home/kier";
    isNormalUser = true;
    name = "kier";
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
    useDefaultShell = true;
  };
}
