{
  imports = [
    <nixpkgs/nixos/modules/virtualisation/lxc-container.nix>
  ];

  # Fix multiple agetty instances being spawned on the same terminal.
  systemd.services."getty@".unitConfig = {
    ConditionVirtualisation = "!lxc";
  };
}
