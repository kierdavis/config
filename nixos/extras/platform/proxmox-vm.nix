{ config, lib, pkgs, ...}: {
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
    ./grub.nix
  ];
}
