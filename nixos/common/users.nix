{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets.nix;

in {
  # Force live user info to match what's declared in this file.
  users.mutableUsers = false;

  users.users.root = {
    # TODO: remove this
    hashedPassword = secrets.hashedUserPasswords.root;
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
  };

  users.users.kier = {
    createHome = true;
    description = "Kier Davis";
    extraGroups = ["wheel" "networkmanager"];
    hashedPassword = secrets.hashedUserPasswords.kier;
    home = "/home/kier";
    isNormalUser = true;
    name = "kier";
    openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
    useDefaultShell = true;
  };
}
