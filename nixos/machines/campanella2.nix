# Campanella2 is a VPS hosting network shares and other services.
# It is named after the band "Wednesday Campanella".

let
  cascade = import ../cascade.nix;

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

  dns-server = { config, lib, pkgs, ... }: {
    services.unbound = {
      enable = true;
      interfaces = [ "0.0.0.0" ];
      allowedAccess = [ "0.0.0.0/0" ];
      forwardAddresses = cascade.upstreamNameservers;
      extraConfig = let
        mkRecord = name: addr: let
          isIPv6 = lib.strings.hasInfix ":" addr;
          recordType = if isIPv6 then "AAAA" else "A";
        in ''local-data: "${name}. IN ${recordType} ${addr}"'';
      in ''
        local-zone: "cascade." static
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList mkRecord cascade.addrs)}
      '';
    };
    networking.firewall.allowedTCPPorts = [ 53 ];
    networking.firewall.allowedUDPPorts = [ 53 ];
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/linode.nix
    ../extras/headless.nix
    ../extras/netfs/cherry.nix
    http-server
    dns-server
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
    ips = [ "${cascade.addrs."campanella2.h.cascade"}/112" ];
    listenPort = cascade.vpn.port;
    privateKeyFile = "/etc/cascade.wg-priv-key";
    peers = with cascade.vpn.peers; [ altusanima motog5 saelli ];
  };
  networking.firewall.allowedUDPPorts = [ cascade.vpn.port ];
}
