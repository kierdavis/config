let
  samba = import ../samba.nix;

  postgresql = { config, lib, pkgs, ... }: {
    services.postgresql = {
      enable = true;
      dataDir = "/srv/postgresql";
    };
  };

  quassel = { config, lib, pkgs, ... }: {
    networking.firewall.allowedTCPPorts = [ 4242 ];

    services.quassel = {
      enable = true;
      dataDir = "/srv/quassel";
      interfaces = [ "0.0.0.0" ];
      portNumber = 4242;
    };

    systemd.services.quassel.after = [ "network.target" "network-online.target" "postgresql.service" ];
  };

  transmission = { config, lib, pkgs, ... }: {
    networking.firewall.allowedTCPPorts = [9091 51413];
    networking.firewall.allowedUDPPorts = [6771 51413];

    users.users.kier.extraGroups = ["transmission"];

    services.transmission.enable = true;
    services.transmission.port = 9091; # web interface
    services.transmission.settings = import ../transmission-settings.nix // {
      download-dir = "/shares/torrents";
    };

    fileSystems."/var/lib/transmission" = {
      device = "/srv/transmission";
      options = ["bind"];
    };

    systemd.services.transmission.serviceConfig.ExecStartPre = lib.mkForce "";
    systemd.services.quassel.after = [ "network.target" "network-online.target" ];
  };

  http = { config, lib, pkgs, ... }: {
    services.httpd = {
      enable = true;
      adminAddr = "kierdavis@gmail.com";
      documentRoot = "/srv/http";
      listen = [ { ip = "*"; port = 80; } ];
    };

    networking.firewall.allowedTCPPorts = [ 80 ];

    users.users.kier.extraGroups = [ "wwwrun" ];
  };

in

{ config, lib, pkgs, ... }:

{
  imports = [
    ../common
    ../extras/boot-grub.nix
    ../extras/headless.nix
    samba.server
    postgresql
    quassel
    transmission
    http
  ];

  machine = {
    name = "nocturn";
    hostId = "ee9e88c0";
    vboxHost = false;
    wifi = false;
    bluetooth = false;

    cpu = {
      cores = 2;
      intel = true;
    };

    fsdevices = {
      root = "/dev/disk/by-uuid/862fe5b3-ab0a-4719-a575-f604c5c1346f";
      grub = "/dev/disk/by-id/wwn-0x50014ee6006f9b4d";
      swap = "/dev/disk/by-uuid/e907b34a-06ff-481b-9bcd-a428fa973db0";
    };
  };

  boot.initrd.availableKernelModules = [ "ata_generic" "uhci_hcd" "ehci_pci" "ahci" "sd_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # Don't go to sleep when lid is closed.
  services.logind.extraConfig = "HandleLidSwitch=ignore";

  # Additional filesystems (LVM).
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/d9f15852-c0bc-49a6-8112-ab36b2ab5a8e";
    fsType = "ext4";
  };
  fileSystems."/shares" = {
    device = "/dev/disk/by-uuid/876ef70b-0794-49c5-840b-11dcb2cec964";
    fsType = "ext4";
  };
  fileSystems."/srv" = {
    device = "/dev/disk/by-uuid/1e20b7fa-e493-404d-bc6c-84f9922a4f0b";
    fsType = "ext4";
  };
}
