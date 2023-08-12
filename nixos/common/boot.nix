{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [ "kvm-intel" ];
  hardware.enableAllFirmware = false;

  # Microcode updates
  hardware.cpu.intel.updateMicrocode = config.machine.cpu.intel;

  # Enable all magic sysrq keys (by default, only sync is enabled).
  boot.kernel.sysctl."kernel.sysrq" = 1;

  boot.enableContainers = false;
}
