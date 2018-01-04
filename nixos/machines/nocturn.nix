# Nocturn is a laptop posing a server hosting network shares and other services.
# It is named after the album "Nocturn" by "Tonebox".

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

  hydra = { config, lib, pkgs, ... }: {
    services.hydra = {
      enable = true;
      dbi = "dbi:Pg:dbname=hydra;user=hydra;";
      extraEnv = {
        HYDRA_DATA = "/srv/hydra";
      };
      listenHost = "*";
      port = 3000;
      hydraURL = "http://soton:9094/";
      notificationSender = "hydra@nocturn";
    };

    networking.firewall.allowedTCPPorts = [ 3000 ];
  };

  pki-ca = { config, lib, pkgs, ... }: {
    environment.systemPackages = [ pkgs.easyrsa ];
    environment.variables.EASYRSA = "/srv/easyrsa";
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
    pki-ca
  ];

  machine = {
    name = "nocturn";
    hostId = "ee9e88c0";
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

    vpn = {
      clientCert = ../../secret/pki/nocturn.crt;
      clientKey = ../../secret/pki/nocturn.key;
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

  # Automatic backups.
  fileSystems."/mnt/backup-tmp" = {
    device = "/dev/disk/by-uuid/80932810-41b1-4c7f-827c-b273d4303b38";
    fsType = "ext4";
  };
  systemd.services.backup = {
    description = "Automatic backup";
    requires = [ "local-fs.target" "network.target" ];
    script = ''
      #!${pkgs.stdenv.shell}
      set -o errexit -o pipefail -o nounset
      date=$(${pkgs.coreutils}/bin/date +%Y%m%d)
      name=nocturn-$date.tar.bz2.gpg
      localfile=/mnt/backup-tmp/$name
      remotefile=backup/nocturn/$date/$name
      recipient=8139C5FCEDA73ABF

      ${pkgs.gnutar}/bin/tar --create --to-stdout /home /srv /shares/{documents,misc,music} \
          --exclude /shares/misc/vm \
        | ${pkgs.pbzip2}/bin/pbzip2 --stdout \
        | ${pkgs.gnupg}/bin/gpg --encrypt --recipient=$recipient --compress-algo=none \
          --output=$localfile --batch
      ${pkgs.backblaze-b2}/bin/backblaze-b2 upload_file KierBackup $localfile $remotefile

      ${pkgs.coreutils}/bin/rm --force $localfile
    '';
    startAt = "Thu 04:00";
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
