{ config, lib, pkgs, ... }:

let
  nvidia_x11 = pkgs.linuxPackages.nvidia_x11.override { libsOnly = true; };
in {
  services.boinc = {
    enable = true;
    dataDir = "/var/lib/boinc";
    allowRemoteGuiRpc = true;
    extraEnvPackages = [
      pkgs.virtualbox
      pkgs.ocl-icd
    ] ++ lib.optional config.machine.gpu.nvidia nvidia_x11;
  };

  environment.systemPackages = [ pkgs.boincmgr ];
}
