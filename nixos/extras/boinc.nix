{ config, lib, pkgs, ... }:

let
  boincDir = "/var/lib/boinc";
  nvidia_x11 = pkgs.linuxPackages.nvidia_x11.override { libsOnly = true; };
in {
  fileSystems.boinc = {
    mountPoint = boincDir;
    device = "/dev/disk/by-label/boinc0";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };

  services.boinc = {
    enable = true;
    dataDir = boincDir;
    allowRemoteGuiRpc = true;
    extraEnvPackages = [
      pkgs.virtualbox
      pkgs.ocl-icd
    ] ++ lib.optional config.machine.gpu.nvidia nvidia_x11;
  };

  environment.systemPackages = [ pkgs.boincmgr ];
}
