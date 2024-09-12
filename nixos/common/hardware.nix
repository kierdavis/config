{ config, lib, pkgs, ... }:

{
  services.udev.extraRules = ''
    # Teensy stuff from https://www.pjrc.com/teensy/00-teensy.rules
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", ENV{ID_MM_DEVICE_IGNORE}="1", ENV{ID_MM_PORT_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789a]*", ENV{MTP_NO_PROBE}="1"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04*", RUN:="${pkgs.coreutils}/bin/stty -F /dev/%k raw -echo"

    # 3D printer
    ACTION=="add", SUBSYSTEM=="tty", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", SYMLINK+="geeetech-prusa-i3"
  '';

  # If hardware-controlled P-state management is available, use it.
  # In this case, the intel_pstate driver defaults to active mode and the governor should be set to powersave (schedutil doesn't exist here).
  # Otherwise, the intel_pstate driver defaults to passive mode and the govenor should be set to schedutil.
  # See also:
  #   https://www.kernel.org/doc/html/v6.1/admin-guide/pm/intel_pstate.html
  #   https://www.reddit.com/r/linux/comments/ihdozd/linux_kernel_58_defaults_to_passive_mode_for/
  powerManagement.cpuFreqGovernor = if config.machine.cpu.intel && config.machine.cpu.hwp then "powersave" else "schedutil";
}
