{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/profiles/qemu-guest.nix>
  ];

  # Configure serial port for LISH.
  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial;
    terminal_output serial
  '';

  # Configure compatiblity with host GRUB.
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  # Tools commonly used by Linode support to debug issues.
  environment.systemPackages = with pkgs; [
    inetutils
    mtr
    sysstat
  ];
}
