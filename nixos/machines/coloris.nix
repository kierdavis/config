# Coloris is my workstation / gaming PC, built in 2016.
# It is named after the album "Coloris" by "she".

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/platform/efi.nix
    # ../extras/boinc.nix
    ../extras/desktop
    ../extras/audio/pulse.nix
    ../extras/devel.nix
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "coloris";
    ipv6-internet = false;
    cpu = {
      cores = 4;
      intel = true;
      hwp = true;
    };
    gpu = {
      nvidia = true;
    };
    i3blocks = {
      cpuThermalZone = "thermal_zone2";
      ethInterface = "enp3s0";
    };
    #jackDevice = "hw:Device,0"; # USB headphones
    jackDevice = "hw:PCH,0"; # Motherboard audio
  };

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/059315e0-e130-475c-9d84-45e4ef750a6b";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/7ea83533-f78b-4deb-94ed-6bef5dbfa8e4";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems.efi.device = "/dev/disk/by-uuid/05BB-9C39";
  swapDevices = [{ device = "/dev/disk/by-uuid/30a2081b-5372-43ec-8346-bc89e3503792"; }];

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "db4d501a";

  # From nixos-generate-config.
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbcore" "sd_mod" "sr_mod" ];

  services.autorandr = {
    enable = true;
    profiles.main = {
      fingerprint = {
        # Left - ASUS
        "HDMI-0" = "00ffffffffffff0006b3da2407460300231c010380341d782a4995a556529f270d5054bfef00d1c0b30095008180814081c0714f0101023a801871382d40582c450009252100001e000000ff004a384c4d54463231343533350a000000fd00324b185311000a202020202020000000fc00415355532056503234370a202001a302031a314f0102031112130414050e0f1d1e1f9065030c0010008c0ad08a20e02d10103e9600092521000018011d007251d01e206e28550009252100001e011d00bc52d01e20b828554009252100001e8c0ad090204031200c4055000925210000180000000000000000000000000000000000000000000000000000000000f3";
        # Right - MSI
        "HDMI-1" = "00ffffffffffff003669d33c010101012f200103803c22782a0fc5a85443ae270d5054bfcf00d1c0714f81c0814081809500b300d1fc565e00a0a0a029503020350055502100001a40e7006aa0a067500820980455502100001a000000fd0030901ee13c000a202020202020000000fc004d534920473237325150460a20019802034af14b0413904c3f5f606103120123091707830100006c030c001000383c200021010067d85dc4017880016d1a000002013090e60000000000e305e301e30fc000e606070153531c6fc200a0a0a055503020350055502100001aba8900a0a0a055503020350055502100001e0000000000000000000000000000000000f4";
      };
      config = {
        "HDMI-0" = {
          mode = "1920x1080";
          position = "0x0";
          rotate = "right";
          primary = true;
        };
        "HDMI-1" = {
          mode = "2560x1440";
          position = "1080x466";
        };
      };
    };
  };

  services.x2goserver.enable = true;
}
