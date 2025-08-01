{ config, lib, pkgs, ... }:

{
  users.groups.nixremotebuild = {};
  users.users.nixremotebuild = {
    createHome = false;
    description = "nix remote build";
    group = "nixremotebuild";
    home = "/var/empty";
    isNormalUser = true;
    name = "nixremotebuild";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIeWvusIi7wgwa2K4+ZN3QUsLgXx/JKoX0zLuxTfx/2n hydra"
    ];
    useDefaultShell = true;
  };
  # Because https://github.com/NixOS/nix/issues/2789
  nix.settings.extra-trusted-users = [ "nixremotebuild" ];

  # Allows SSH connections to this host from Hydra.
  services.tailscale.advertiseTags = ["nix-builder"];
}
