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

  http-server = { config, lib, pkgs, ... }: {
    services.nginx = {
      enable = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts = (import ../../secret/campanella2-vhosts.nix) // {
        "gendershake.dev.eleanor.cool" = {
          enableACME = true;
          forceSSL = true;
          root = "/srv/http/gendershake.dev.eleanor.cool";
          extraConfig = ''
            index index.php;
          '';
          locations."~* \.php$".extraConfig = ''
            fastcgi_pass unix:/var/run/phpfpm.default.sock;
            include ${pkgs.nginx}/conf/fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param SCRIPT_NAME $fastcgi_script_name;
          '';
        };
        default = {
          default = true;
          root = "/srv/http/default/www";
        };
      };
    };
    services.phpfpm.pools.default = {
      listen = "/var/run/phpfpm.default.sock";
      extraConfig = ''
        listen.owner = nginx
        listen.group = nginx
        user = nginx
        group = nginx
        pm = ondemand
        pm.max_children = 8
      '';
    };
    systemd.services.nginx.after = [ "srv.mount" ];
    systemd.services.nginx.requires = [ "srv.mount" ];
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };

  cascade = import ../cascade.nix;

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/linode.nix
    ../extras/headless.nix
    ../extras/netfs/cherry.nix
    http-server
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
  # Not enough RAM for a tmpfs
  boot.tmpOnTmpfs = lib.mkForce false;
  boot.cleanTmpDir = true;

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
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${cascade.hosts.campanella2.addrs.vpn}/112" ];
    listenPort = cascade.vpnPort;
    privateKeyFile = "/etc/cascade.wg-priv-key";
    peers = [
      cascade.hosts.altusanima.vpnPeerInfo
      cascade.hosts.saelli.vpnPeerInfo
    ];
  };
  networking.firewall.allowedUDPPorts = [ cascade.vpnPort ];
}
