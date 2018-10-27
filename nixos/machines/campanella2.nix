# Campanella2 is a VPS hosting network shares and other services.
# It is named after the band "Wednesday Campanella".

let
  postgresql-server = { config, lib, pkgs, ... }: {
    services.postgresql = {
      enable = true;
      dataDir = "/srv/postgresql";
      extraConfig = ''
        listen_addresses = '127.0.0.1, 10.99.0.1'
      '';
      authentication = ''
        host all all 10.99.0.0/16 md5
      '';
    };
    systemd.services.postgresql.after = [ "srv.mount" ];
    systemd.services.postgresql.requires = [ "srv.mount" ];
    networking.firewall.allowedTCPPorts = [ 5432 ];
  };

  irc-client = { config, lib, pkgs, ... }: {
    services.quassel = {
      enable = true;
      dataDir = "/srv/quassel";
      interfaces = [ "0.0.0.0" ];
    };
    systemd.services.quassel.after = [ "postgresql.service" "srv.mount" ];
    systemd.services.quassel.requires = [ "postgresql.service" "srv.mount" ];
    networking.firewall.allowedTCPPorts = [ 4242 ];
  };

  http-client = { config, lib, pkgs, ... }: {
    services.nginx = {
      enable = true;
      virtualHosts = (import ../../secret/campanella2-vhosts.nix) // {
        default = {
          default = true;
          root = "/srv/http/default/www";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    users.users.nginx = {
      useDefaultShell = true;
      openssh.authorizedKeys.keyFiles = [ ../../ssh-keys ];
    };
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/linode.nix
    ../extras/headless.nix
    ../extras/netfs/gyroscope.nix
    postgresql-server
    irc-client
    http-client
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "campanella2";
    wifi = false;
    cpu = {
      cores = 1;
      intel = true;
    };
  };

  # Filesystems.
  fileSystems."/" = {
    device = "/dev/sda";
    fsType = "ext4";
    options = ["noatime" "nodiratime"];
  };
  fileSystems."/home" = {
    device = "/dev/sdc";
    fsType = "ext4";
  };
  fileSystems."/srv" = {
    device = "/dev/sde";
    fsType = "ext4";
  };
  swapDevices = [ { device = "/dev/sdb"; } ];

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "0e6e63bc";

  # From nixos-generate-config.
  boot.initrd.availableKernelModules = [ "ata_piix" "virtio_pci" "floppy" "sd_mod" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  # VPN server config.
  campanella-vpn.server = {
    enable = true;
    certFile = ../../secret/vpn/certs/campanella2.crt;
    keyFile = "/etc/campanella2.key";
  };
}
