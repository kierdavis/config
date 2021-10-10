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
}
