{ config, lib, pkgs, ... }:

{
  services.boinc = {
    enable = true;
    dataDir = "/var/data/boinc";
    allowRemoteGuiRpc = true;
    useFHSEnv = true;
    virtualbox.enable = true;
    gpu.enable = true;
    gpu.nvidia.enable = true;
  };
}
