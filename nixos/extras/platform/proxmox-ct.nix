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

  # Fix device nodes being unavailable.
  boot.postBootCommands = ''
    # /dev/net/tun
    # https://vroomtech.io/enable-tuntap-in-a-proxmox-lxc-container/
    if [ ! -c /dev/net/tun ]; then
      mkdir -p /dev/net
      mknod -m 666 /dev/net/tun c 10 200
    fi

    # /dev/fuse
    # https://forum.proxmox.com/threads/kernel-module-fuse-for-lxc.24855/
    if [ ! -c /dev/fuse ]; then
      mknod -m 666 /dev/fuse c 10 229
    fi
  '';
}
