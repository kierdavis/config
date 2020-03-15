{ config, pkgs, lib, ... }:

let
  bootConfig = pkgs.writeTextFile {
    name = "config.txt";
    text = ''
      # managed by NixOS

      kernel=u-boot-rpi3.bin

      # Boot in 64-bit mode.
      arm_control=0x200

      # U-Boot used to need this to work, regardless of whether UART is actually used or not.
      # TODO: check when/if this can be removed.
      enable_uart=1

      # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
      # when attempting to show low-voltage or overtemperature warnings.
      avoid_warnings=1
    '';
  };

in {
  options = with lib; {
    raspberryPi = {
      firmwareFS = {
        device = mkOption {
          type = types.path;
          default = "/dev/mmcblk0p1";
          description = ''Device containing the firmware filesystem.'';
        };
      };
    };
  };

  config = {
    # NixOS wants to enable GRUB by default
    boot.loader.grub.enable = false;
    # Enables the generation of /boot/extlinux/extlinux.conf
    boot.loader.generic-extlinux-compatible.enable = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.tmpOnTmpfs = lib.mkForce false;

    services.xserver.videoDrivers = ["fbdev"];

    nix.gc.automatic = false;

    fileSystems."/boot/fw" = {
      device = config.raspberryPi.firmwareFS.device;
      fsType = "vfat";
    };

    systemd.services.bootloader-config = {
      description = "Bootloader configuration";
      wantedBy = [ "basic.target" ];
      requires = [ "boot-fw.mount" ];
      after = [ "boot-fw.mount" ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        cp -L ${bootConfig} /boot/fw/config.txt
      '';
    };
  };
}
