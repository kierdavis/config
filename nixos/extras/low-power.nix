# https://wiki.archlinux.org/index.php/Power_management#Power_saving
# http://www.thinkwiki.org/wiki/How_to_reduce_power_consumption

{ config, pkgs, lib, ... }:

{
  boot.extraModprobeConfig = ''
    # Put audio hardware to sleep after 1 second of inactivity (Intel hardware).
    options snd_hda_intel power_save=1

    # Wi-fi power saving (Intel hardware).
    options iwlwifi power_save=1 uapsd_disable=0
    options iwlmvm power_scheme=3
    options iwldvm force_cam=0
  '';

  boot.kernelParams = [
    # Enable PCIe Active State Power Management (shuts down the link when there's no traffic across it).
    "pcie_aspm.policy=powersave"
  ];

  boot.kernel.sysctl = {
    # Disable NMI watchdog (generates lots of interrupts, mainly a debugging feature).
    "kernel.nmi_watchdog" = 0;

    # Increase dirty virtual memory writeback time.
    # (commented out because vm.laptop_mode also sets this)
    #"vm.dirty_writeback_centisecs" = 6000;

    # https://www.kernel.org/doc/Documentation/laptops/laptop-mode.txt
    "vm.laptop_mode" = 5;
  };

  services.udev.extraRules = ''
    # USB autosuspend blacklist
    # Tecknet wireless mouse
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="062a", ATTR{idProduct}=="5918", GOTO="power_usb_rules_end"

    # Enable USB autosuspend by default for all other devices.
    #ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    LABEL="power_usb_rules_end"
  '';

  services.xserver.displayManager.sessionCommands = ''
    # Turn off display after 5 minutes of idling.
    xset +dpms
    xset dpms 0 0 300
  '';

  services.xserver.deviceSection = ''
    # Disable DRI (graphics acceleration).
    Option "NoDRI"
  '';

  # TODO: check bluetooth, btusb unloaded

  # Install powertop
  environment.systemPackages = with pkgs; [ powertop ];
}
