# OUT OF DATE!

# Gyroscope is a Raspberry Pi hosting network shares and other services.
# It is named after the album "Gyroscope" by "Boards of Canada".

let
  nfsServer = { config, lib, pkgs, ... }: let
    mountUnits = [
      "net-gyroscope-archive.mount"
      "net-gyroscope-misc\\x2dlarge.mount"
      "net-gyroscope-music.mount"
      "net-gyroscope-torrents.mount"
      "net-gyroscope-video.mount"
    ];
  in {
    services.nfs.server = {
      enable = true;
      createMountPoints = true;
      exports = ''
        /net/gyroscope/archive 10.99.0.0/16(ro,all_squash,anonuid=1000,anongid=100)
        /net/gyroscope/misc-large 10.99.0.0/16(rw,all_squash,anonuid=1000,anongid=100)
        /net/gyroscope/music 10.99.0.0/16(rw,all_squash,anonuid=1000,anongid=100)
        /net/gyroscope/torrents 10.99.0.0/16(ro,all_squash,anonuid=70,anongid=70) # UID and GID for 'transmission'
        /net/gyroscope/video 10.99.0.0/16(rw,all_squash,anonuid=1000,anongid=100)
      '';
    };
    systemd.services = {
      nfs-server.requires = mountUnits;
      nfs-server.after = mountUnits;
      nfs-mountd.requires = mountUnits;
      nfs-mountd.after = mountUnits;
    };
    networking.firewall.allowedTCPPorts = [ 2049 ];
  };

  transmissionClient = { config, lib, pkgs, ... }: let
    nordvpn = import ../../secret/nordvpn { inherit pkgs; };
  in {
    containers.torrent = {
      config = {
        services.openvpn.servers.nordvpn = {
          config = nordvpn.config;
          autoStart = true;
        };
        services.transmission = {
          enable = true;
          port = 9091; # web interface
          settings = import ../transmission-settings.nix // {
            download-dir = "/downloads";
          };
        };
        environment.etc."resolv.conf".text = ''
          # NordVPN name servers
          nameserver 103.86.96.100
          nameserver 103.86.99.100
        '';
        networking.interfaces.eth0.ipv4.routes = [
          { address = "192.168.1.0"; prefixLength = 24; via = "10.66.2.1"; }
          { address = "10.99.0.0"; prefixLength = 16; via = "10.66.2.1"; }
        ];
        networking.firewall.allowedTCPPorts = [ 9091 ];
        networking.firewall.extraCommands = ''
          # Reset the OUTPUT chain (delete all rules and set policy to accept packets by default).
          ip46tables -F OUTPUT
          ip46tables -P OUTPUT ACCEPT
          # Allow traffic to NordVPN's entry point.
          iptables -A OUTPUT --protocol tcp --destination ${nordvpn.host} --dport ${toString nordvpn.port} -j ACCEPT
          # Allow traffic destinated for one of gyroscope's LANs.
          iptables -A OUTPUT --destination 10.66.2.0/24 -j ACCEPT
          iptables -A OUTPUT --destination 192.168.1.0/24 -j ACCEPT
          iptables -A OUTPUT --destination 10.99.0.0/16 -j ACCEPT
          # Disallow all other traffic through eth0.
          ip46tables -A OUTPUT --out-interface eth0 -j REJECT
        '';
      };
      bindMounts = {
        "/downloads" = {
          hostPath = "/net/gyroscope/torrents";
          isReadOnly = false;
        };
        "/var/lib/transmission" = {
          hostPath = "/srv/transmission";
          isReadOnly = false;
        };
      };
      forwardPorts = [
        { hostPort = 9091; containerPort = 9091; protocol = "tcp"; }
      ];
      privateNetwork = true;
      enableTun = true;
      hostAddress = "10.66.2.1";
      localAddress = "10.66.2.2";
      autoStart = true;
    };
    systemd.services."container@torrent" = {
      requires = [ "net-gyroscope-torrents.mount" ];
      after = [ "net-gyroscope-torrents.mount" ];
    };
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-torrent"];
      externalInterface = "eth0";
    };
    users.extraGroups.transmission.gid = config.ids.gids.transmission;
    users.extraUsers.transmission = {
      group = "transmission";
      uid = config.ids.uids.transmission;
      description = "Transmission BitTorrent user";
      home = "/srv/transmission";
    };
    users.users.kier.extraGroups = [ "transmission" ];
    networking.firewall.allowedTCPPorts = [ 9091 ];
  };
in

{ config, lib, pkgs, ... }:
{
  imports = [
    ../common
    ../extras/platform/raspberry-pi-3.nix
    ../extras/headless.nix
    nfsServer
    transmissionClient
  ];

  machine = {
    name = "gyroscope";
    wifi = false;

    cpu = {
      cores = 4;
    };

    fsdevices = {
      boot = "/dev/disk/by-label/boot0";
      root = "/dev/disk/by-label/root0";
      swap = "/dev/disk/by-label/swap0";
      tmp = "/dev/disk/by-label/tmp0";
    };
  };

  networking.hostId = "abee6add";

  boot.initrd.availableKernelModules = [ "usb_storage" ];
  powerManagement.cpuFreqGovernor = "ondemand";

  campanella-vpn.client = {
    enable = true;
    certFile = ../../secret/vpn/certs/gyroscope.crt;
    keyFile = "/etc/gyroscope.key";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/home0";
    fsType = "ext4";
  };
  fileSystems."/net/gyroscope/archive" = {
    device = "/dev/disk/by-label/archive0";
    fsType = "ext4";
  };
  fileSystems."/net/gyroscope/misc-large" = {
    device = "/dev/disk/by-label/misc_large0";
    fsType = "ext4";
  };
  fileSystems."/net/gyroscope/music" = {
    device = "/dev/disk/by-label/music0";
    fsType = "ext4";
  };
  fileSystems."/net/gyroscope/torrents" = {
    device = "/dev/disk/by-label/torrents0";
    fsType = "ext4";
  };
  fileSystems."/net/gyroscope/video" = {
    device = "/dev/disk/by-label/video0";
    fsType = "ext4";
  };

  boot.initrd.preLVMCommands = ''
    echo "Sleeping for a few seconds to wait for the hard disk to spin up..."
    sleep 4
  '';
}
