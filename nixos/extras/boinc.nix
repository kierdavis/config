{ config, lib, pkgs, ... }:

let
  boincDir = "/var/lib/boinc";
  nvidia_x11 = pkgs.linuxPackages.nvidia_x11.override { libsOnly = true; };
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
    extraEnvPackages = [
      pkgs.virtualbox
      pkgs.ocl-icd
    ] ++ lib.optional config.machine.gpu.nvidia nvidia_x11;
  };
}
