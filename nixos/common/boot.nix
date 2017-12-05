{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  hardware.enableAllFirmware = true;

  # Microcode updates
  hardware.cpu.intel.updateMicrocode = config.machine.cpu.intel;
}
