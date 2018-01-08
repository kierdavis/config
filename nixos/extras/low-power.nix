# https://wiki.archlinux.org/index.php/Power_management#Power_saving

{ config, pkgs, lib, ... }:

{
  boot.extraModprobeConfig = ''
    # Put audio hardware to sleep after 1 second of inactivity (Intel hardware).
    options snd_hda_intel power_save=1

    # Wi-fi power saving (Intel hardware).
    options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
    options iwldvm force_cam=0
  '';

  boot.blacklistedKernelModules = [
    # Webcam.
    "uvcvideo"
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
    # PCI runtime power management.
    ACTION=="add", SUBSYSTEM=="pci", ATTR(power/control)="auto"

    # USB autosuspend blacklist
    # ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1234", ATTR{idProduct}=="5678", GOTO="power_usb_rules_end"

    # Enable USB autosuspend by default for all other devices.
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"
    LABEL="power_usb_rules_end"
  '';

  # TODO: check bluetooth, btusb unloaded
}
