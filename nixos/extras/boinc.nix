{ config, lib, pkgs, ... }:

let
  boincDir = "/var/lib/boinc";
in {
  imports = [ ../lib/boinc-fhs.nix ];

  fileSystems.boinc = {
    mountPoint = boincDir;
    device = "/dev/hdd/boinc";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };

  services.boinc-fhs = {
    enable = true;
    dataDir = boincDir;
    allowRemoteGuiRpc = true;
    useFHSEnv = true;
    virtualbox.enable = true;
    gpu.enable = true;
    gpu.nvidia.enable = true;
  };
}
