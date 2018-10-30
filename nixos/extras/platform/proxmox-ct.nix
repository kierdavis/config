{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/lxc-container.nix>
  ];

  # Fix multiple agetty instances being spawned on the same terminal.
  systemd.services."getty@".unitConfig = {
    ConditionVirtualization = "!lxc";
  };

  # Fix "unable to make '/' private mount: Permission denied"
  nix.useSandbox = lib.mkForce false;

  # Fix /dev/net/tun being unavailable.
  # https://vroomtech.io/enable-tuntap-in-a-proxmox-lxc-container/
  boot.postBootCommands = ''
    if [ ! -c /dev/net/tun ]; then
      mkdir -p /dev/net
      mknod -m 666 /dev/net/tun c 10 200
    fi
  '';
}
