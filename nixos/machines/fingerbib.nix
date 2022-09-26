let
  passwords = import ../../secret/passwords.nix;

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
          networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
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
          users.groups.media = config.users.groups.media;
          services.transmission = {
            enable = true;
            home = "/var/lib/transmission";
            user = "transmission";
            group = "media";
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
              utp-enabled = true;
              encryption = 2;
              speed-limit-up = 2000;
              speed-limit-up-enabled = true;
              speed-limit-down = 2000;
              speed-limit-down-enabled = true;
              alt-speed-up = 200;
              alt-speed-down = 200;
              alt-speed-enabled = false; # "turtle" mode
              rpc-enabled = true;
              rpc-bind-address = cfg.containerAddress;
              rpc-port = cfg.httpPort;
              rpc-whitelist-enabled = false;
              rpc-authentication-required = false;
              prefetch-enabled = true;
              cache-size-mb = 100;
              download-queue-enabled = false;
              umask = 18; # decimal equiv of octal 022
            };
          };
        };
      };
      systemd.services."container@transmission".serviceConfig = {
        Nice = 10;
        IOSchedulingClass = "idle";
      };
      networking.firewall.extraCommands = ''
        ip46tables --flush transmission-egress || ip46tables --new-chain transmission-egress
        iptables --append transmission-egress --protocol ${vpnEndpoint.protocol} --destination ${vpnEndpoint.address} --destination-port ${builtins.toString vpnEndpoint.port} --jump ACCEPT
        iptables --append transmission-egress --protocol icmp --icmp-type 8 --destination ${vpnEndpoint.address} --jump ACCEPT
        ip46tables --append transmission-egress --jump REJECT
        ip46tables --append FORWARD --in-interface ve-transmission --jump transmission-egress
      '';
      networking.nat.internalInterfaces = [ "ve-transmission" ];
      local.webServer.virtualHosts.torrents.locations."/".proxyPass = "http://${cfg.containerAddress}:${builtins.toString cfg.httpPort}/";
    };
  };

  webServer = { config, lib, pkgs, ... }: let
    cfg = config.local.webServer;
    defaultVirtualHost = name: {
      listen = [ { addr = "[fdec:affb:e11e:1::3]"; port = 80; } ];
      serverAliases = [ "${name}.hist" ];
    };
  in {
    options.local.webServer = with lib; {
      virtualHosts = mkOption { type = types.attrsOf types.attrs; default = {}; };
    };
    config = {
      services.nginx = {
        enable = true;
        virtualHosts = lib.mapAttrs (name: vh: defaultVirtualHost name // vh) cfg.virtualHosts;
      };
      local.webServer.virtualHosts.default = {
        default = true;
        locations."/".return = ''404 "no such virtual host"'';
      };
    };
  };

  mediaServer = { config, lib, pkgs, ... }: {
    services.jellyfin.enable = true;
    systemd.services.jellyfin.serviceConfig = {
      Nice = -10;
      IOSchedulingClass = "realtime";
    };
    local.webServer.virtualHosts.media.locations."/".proxyPass = "http://localhost:8096/";
    local.webServer.virtualHosts.media-lan = {
      listen = [ { addr = "192.168.178.3"; port = 80; } ];
      serverName = "media";
      serverAliases = [ "media.fritz.box" ];
      default = true;
      locations."/".proxyPass = "http://localhost:8096/";
    };
    networking.firewall.interfaces.br-lan.allowedTCPPorts = [ 80 ];
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
      local.webServer.virtualHosts.printing.locations."/".proxyPass = "http://localhost:631/";
    };
  };

  print3dServer = { config, lib, pkgs, ... }: let
    openboxConfig = pkgs.writeText "openbox-rc.xml" ''
      <?xml version="1.0" encoding="UTF-8"?>
      <openbox_config xmlns="http://openbox.org/3.4/rc"
                      xmlns:xi="http://www.w3.org/2001/XInclude">
        <keyboard>
          <keybind key="W-Return">
            <action name="Execute">
              <command>xterm</command>
            </action>
          </keybind>
          <keybind key="W-S-e">
            <action name="Exit">
              <prompt>yes</prompt>
            </action>
          </keybind>
          <keybind key="A-Tab">
            <action name="NextWindow">
              <finalactions>
                <action name="Focus"/>
                <action name="Raise"/>
                <action name="Unshade"/>
              </finalactions>
            </action>
          </keybind>
          <keybind key="A-S-Tab">
            <action name="PreviousWindow">
              <finalactions>
                <action name="Focus"/>
                <action name="Raise"/>
                <action name="Unshade"/>
              </finalactions>
            </action>
          </keybind>
        </keyboard>
      </openbox_config>
    '';
    startupScript = pkgs.writeShellScript "autostart" ''
      tint2 &
      repetier-host
      openbox --exit
    '';
  in {
    services.xrdp = {
      enable = true;
      defaultWindowManager = "exec ${pkgs.openbox}/bin/openbox --config-file ${openboxConfig} --startup ${startupScript}";
    };
    networking.firewall.allowedTCPPorts = [ config.services.xrdp.port ];
    hardware.opengl.enable = true;
    users.users."3dprint".extraGroups = [ "dialout" ];
    users.users."3dprint".packages = with pkgs; [
      openbox
      prusa-slicer
      repetier-host
      tint2
      xterm
    ];
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    # ../extras/boinc.nix
    # ../extras/headless.nix
    ../extras/platform/grub.nix
    torrentClient
    webServer
    mediaServer
    printServer
    print3dServer
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
    "/data" = { device = "fingerbib/data/data"; fsType = "zfs"; };
    "/data/media" = { device = "fingerbib/data/media"; fsType = "zfs"; };
    "/home" = { device = "fingerbib/data/home"; fsType = "zfs"; };
    "/home/kier/.local/share/containers" = { device = "fingerbib/transient/podman/kier"; fsType = "zfs"; };
    "/nix/store" = { device = "fingerbib/os/nix-store"; fsType = "zfs"; };
    "/tmp" = { device = "fingerbib/transient/tmp"; fsType = "zfs"; };
    "/var/cache" = { device = "fingerbib/transient/cache"; fsType = "zfs"; };
    "/var/lib/containers" = { device = "fingerbib/transient/podman/root"; fsType = "zfs"; };
    "/var/log" = { device = "fingerbib/os/log"; fsType = "zfs"; };
  };
  boot.loader.grub.devices = [
    "/dev/disk/by-id/ata-TOSHIBA_MG03ACA200_258HK26RF"
    "/dev/disk/by-id/ata-ST2000DL003-9VT166_5YD5YEPX"
  ];
  swapDevices = [
    { device = "/dev/disk/by-partlabel/fb_swap"; }
  ];
  boot.tmpOnTmpfs = false;

  # Networking:
  networking.useDHCP = false;
  services.udev.extraRules = ''ACTION=="add", SUBSYSTEM=="net", ATTR{address}=="44:37:e6:bd:b8:54", NAME="en-lan"'';
  networking.bridges.br-lan.interfaces = [ "en-lan" ];
  networking.interfaces.br-lan.ipv4.addresses = [{
    address = "192.168.178.3";
    prefixLength = 24;
  }];
  networking.defaultGateway = {
    address = "192.168.178.1";
    interface = "br-lan";
  };
  networking.nameservers = [ config.networking.defaultGateway.address ];
  networking.nat.enable = true;
  networking.nat.externalInterface = "br-lan";

  # Bit unintuitive, but this tells nixos to install the nvidia kernel module.
  # TODO: finish this. Disabling for now since it breaks swrast.
  # services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;

  torrentClient = {
    hostAddress = "192.168.103.1";
    containerAddress = "192.168.103.2";
    vpn = import ../../secret/nordvpn // { hostName = "nordvpn"; };
  };

  users.groups.media = {
    gid = 398;
  };
  users.groups."3dprint" = {
    gid = 397;
  };
  users.users.kier.extraGroups = ["media" "3dprint"];
  users.users.media = {
    description = "Media Services";
    uid = config.users.groups.media.gid;
    group = "media";
    home = "/data/media";
    isSystemUser = true;
    useDefaultShell = true;
  };
  users.users."3dprint" = {
    description = "3D Printing Services";
    uid = config.users.groups."3dprint".gid;
    group = "3dprint";
    home = "/data/3dprint";
    isSystemUser = true;
    useDefaultShell = true;
    hashedPassword = passwords.user.fingerbib-3dprint.hashed;
  };
  users.users.transmission = {
    description = "Transmission BitTorrent user";
    uid = config.ids.uids.transmission;
    group = "media";
    home = "/data/media/torrents";
    isSystemUser = true;
    useDefaultShell = true;
  };

  # Allow media user to create hardlinks to files owned by transmission.
  boot.kernel.sysctl."fs.protected_hardlinks" = 0;
}
