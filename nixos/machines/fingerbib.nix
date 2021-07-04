let
  hist = import ../../hist.nix;

  torrentClient = { config, lib, pkgs, ... }: {
    options.torrentClient = with lib; {
      hostAddress = mkOption { type = types.str; };
      containerAddress = mkOption { type = types.str; };
      httpPort = mkOption { type = types.int; default = 8000; };
      vpn.configFile = mkOption { type = types.path; };
      vpn.username = mkOption { type = types.str; };
      vpn.password = mkOption { type = types.str; };
      vpn.hostName = mkOption { type = types.str; default = "vpn"; };
    };
    config = let
      cfg = config.torrentClient;
      vpnEndpoint = import (pkgs.runCommand "nordvpn-endpoint.nix" {} ''
        echo "{" >> $out
        awk '/^remote /{print "address=\""$2"\";port="$3";"}' < ${cfg.vpn.configFile} >> $out
        awk '/^proto /{print "protocol=\""$2"\";"}' < ${cfg.vpn.configFile} >> $out
        echo "}" >> $out
      '');
    in {
      networking.hosts."${vpnEndpoint.address}" = [cfg.vpn.hostName];
      containers.transmission = {
        autoStart = true;
        ephemeral = true;
        privateNetwork = true;
        enableTun = true;
        hostAddress = cfg.hostAddress;
        localAddress = cfg.containerAddress;
        bindMounts."/downloads" = {
          hostPath = "/data/media/torrents";
          isReadOnly = false;
        };
        bindMounts."/var/lib/transmission" = {
          hostPath = "/var/lib/transmission";
          isReadOnly = false;
        };
        config = {
          imports = [
            ../common/apps.nix
            ../common/bugfixes.nix
            ../common/env.nix
            ../common/locale.nix
            ../common/nix.nix
            ../common/options.nix
          ];
          machine.name = "transmission";
          machine.cpu.cores = 8;
          networking.useDHCP = false;
          networking.defaultGateway = {
            address = cfg.hostAddress;
            interface = "eth0";
          };
          networking.nameservers = hist.upstreamNameServers;
          networking.hosts."${vpnEndpoint.address}" = [cfg.vpn.hostName];
          networking.firewall.enable = true;
          networking.firewall.interfaces.eth0.allowedTCPPorts = [ cfg.httpPort ];
          services.openvpn.servers.vpn = {
            config = ''
              config "${cfg.vpn.configFile}"
              dev tun-vpn
            '';
            authUserPass = { inherit (cfg.vpn) username password; };
          };
          services.transmission = {
            enable = true;
            home = "/var/lib/transmission";
            settings = {
              download-dir = "/downloads";
              incomplete-dir-enabled = false;
              rename-partial-files = true;
              start-added-torrents = true;
              trash-original-torrent-files = false;
              watch-dir-enabled = false;
              dht-enabled = true;
              lpd-enabled = true;
              pex-enabled = true;
              prefetch-enabled = true;
              utp-enabled = true;
              encryption = 2;
              speed-limit-up = 1000;
              speed-limit-up-enabled = true;
              speed-limit-down = 1000;
              speed-limit-down-enabled = true;
              alt-speed-up = 200;
              alt-speed-down = 200;
              alt-speed-enabled = false; # "turtle" mode
              rpc-enabled = true;
              rpc-bind-address = cfg.containerAddress;
              rpc-port = cfg.httpPort;
              rpc-whitelist-enabled = false;
              rpc-authentication-required = false;
            };
          };
        };
      };
      networking.firewall.extraCommands = ''
        ip46tables --flush transmission-egress || ip46tables --new-chain transmission-egress
        iptables --append transmission-egress --protocol ${vpnEndpoint.protocol} --destination ${vpnEndpoint.address} --destination-port ${builtins.toString vpnEndpoint.port} --jump ACCEPT
        iptables --append transmission-egress --protocol icmp --icmp-type 8 --destination ${vpnEndpoint.address} --jump ACCEPT
        ip46tables --append transmission-egress --jump REJECT
        ip46tables --append FORWARD --in-interface ve-transmission --jump transmission-egress
      '';
      networking.nat.internalInterfaces = [ "ve-transmission" ];
      hist.local.webServer.virtualHosts.torrents.locations."/".proxyPass = "http://${cfg.containerAddress}:${builtins.toString cfg.httpPort}/";
    };
  };

  webServer = { config, lib, pkgs, ... }: let
    cfg = config.hist.local.webServer;
    defaultVirtualHost = name: {
      listen = [ { addr = "[${cfg.address}]"; port = cfg.httpPort; } ];
      serverAliases = [ "${name}.hist" ];
    };
  in {
    options.hist.local.webServer = with lib; {
      address = mkOption { type = types.str; default = hist.hosts.fingerbib.addresses.default.private; };
      httpPort = mkOption { type = types.int; default = 80; };
      virtualHosts = mkOption { type = types.attrsOf types.attrs; default = {}; };
    };
    config = {
      services.nginx = {
        enable = true;
        virtualHosts = lib.mapAttrs (name: vh: defaultVirtualHost name // vh) cfg.virtualHosts;
      };
      hist.local.webServer.virtualHosts.default = {
        default = true;
        locations."/".return = ''404 "no such virtual host"'';
      };
      networking.firewall.interfaces.wg-hist.allowedTCPPorts = [ cfg.httpPort ];
    };
  };

  mediaServer = { config, lib, pkgs, ... }: {
    services.jellyfin.enable = true;
    hist.local.webServer.virtualHosts.media.locations."/".proxyPass = "http://[::1]:8096/";
  };

  /*
  icinga = { config, lib, pkgs, ... }: {
    services.icingaweb2 = {
      enable = true;
      virtualHost = "fingerbib-icinga";
      authentications.autologin.backend = "external";
      modules.monitoring.enable = true;
    };
    services.nginx.virtualHosts."fingerbib-icinga" = {
      listen = config.services.nginx.virtualHosts.default.listen;
      locations."~ ^/index.php(.*)$".extraConfig = lib.mkAfter "fastcgi_param REMOTE_USER kier;";
    };
  };
  */

  printServer = { config, lib, pkgs, ... }: {
    config = {
      services.printing = {
        enable = true;
        listenAddresses = ["localhost:631"];
        drivers = [
          pkgs.gutenprint
          # pkgs.cups-brother-hl1110
          pkgs.hplip
        ];
      };
      hist.local.webServer.virtualHosts.printing.locations."/".proxyPass = "http://localhost:631/";
    };
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/headless.nix
    ../extras/platform/grub.nix
    torrentClient
    webServer
    mediaServer
    printServer
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "fingerbib";
    cpu = {
      cores = 8;
      intel = true;
    };
  };
  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "74e71470";

  powerManagement.cpuFreqGovernor = "ondemand";

  # Need at least kernel 5.8 for container names > 11 characters (needs interface altnames).
  boot.kernelPackages =
    if builtins.compareVersions pkgs.linuxPackages.kernel.version "5.8" <= 0
      then pkgs.linuxPackages_5_10
      else pkgs.linuxPackages;

  # Filesystems:
  boot.supportedFilesystems = ["zfs"];
  fileSystems = {
    "/" = { device = "fingerbib/os/root"; fsType = "zfs"; };
    "/boot" = { device = "/dev/disk/by-partlabel/fb_boot1"; fsType = "ext4"; };
    "/data/media" = { device = "fingerbib/data/media"; fsType = "zfs"; };
    "/home" = { device = "fingerbib/data/home"; fsType = "zfs"; };
    "/nix/store" = { device = "fingerbib/os/nix-store"; fsType = "zfs"; };
    "/tmp" = { device = "fingerbib/transient/tmp"; fsType = "zfs"; };
    "/var/cache" = { device = "fingerbib/transient/cache"; fsType = "zfs"; };
    "/var/log" = { device = "fingerbib/os/log"; fsType = "zfs"; };
  };
  boot.loader.grub.device = "/dev/disk/by-id/ata-ST2000DL003-9VT166_5YD5YEPX";
  swapDevices = [
    { device = "/dev/disk/by-partlabel/fb_swap"; }
  ];
  boot.tmpOnTmpfs = false;

  # Networking:
  networking.useDHCP = false;
  services.udev.extraRules = ''ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:37:e6:bd:b8:54", NAME="en-lan"'';
  networking.bridges.br-lan.interfaces = [ "en-lan" ];
  networking.interfaces.br-lan.useDHCP = true;
  networking.nat.enable = true;
  networking.nat.externalInterface = "br-lan";

  torrentClient = {
    hostAddress = "${hist.networks.pointToPoint.prefix}.1";
    containerAddress = "${hist.networks.pointToPoint.prefix}.2";
    vpn = import ../../secret/nordvpn // { hostName = "nordvpn"; };
  };
}
