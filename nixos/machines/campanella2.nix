# Campanella2 is a VPS hosting network shares and other services.
# It is named after the band "Wednesday Campanella".

let
  cascade = import ../cascade.nix;

  dns-server = { config, lib, pkgs, ... }: {
    services.unbound = {
      enable = true;
      interfaces = [ "0.0.0.0" "::" ];
      allowedAccess = [ "0.0.0.0/0" "::/0" ];
      forwardAddresses = cascade.upstreamNameservers;
      extraConfig = let
        mkRecord = entry: let
          isIPv6 = lib.strings.hasInfix ":" entry.addr;
          recordType = if isIPv6 then "AAAA" else "A";
        in ''local-data: "${entry.name}. IN ${recordType} ${entry.addr}"'';
      in ''
        local-zone: "cascade." static
        ${lib.concatStringsSep "\n" (map mkRecord cascade.domainNames)}
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
    dns-server
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "campanella2";
    wifi = false;
    ipv6-internet = true;
    cpu = {
      cores = 1;
      intel = true;
    };
    backup = {
      tempDir = "/home/kier/.cache/duplicity/tmp";
      archiveDir = "/home/kier/.cache/duplicity/archive";
      volumes = [
        {
          name = "git-0";
          path = "/home/kier/srv/git";
          before = ''
            for dir in /home/kier/srv/git/*; do
              ${pkgs.git}/bin/git -C $dir gc --aggressive
            done
          '';
        }
      ];
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
  networking.wireguard.interfaces.wg0 = {
    ips = [ "${cascade.addrs.cv.campanella2}/112" ];
    listenPort = cascade.vpn.port;
    privateKeyFile = "/etc/cascade.wg-priv-key";
    peers = [
      {
        publicKey = "jbol9385zdX7Ctfd3iz1LM3pHbT/zB1YvRg6gMx/zV8=";
        allowedIPs = [
          "${cascade.addrs.cv.altusanima}/128"
          "${cascade.addrs.cl.altusanima}/112"
          "${cascade.addrs.cvl.altusanima}/112"
        ];
        persistentKeepalive = 25;
      }
      {
        publicKey = "Kk29EQEXWlCJxMB14brjEz4/UOixlXPp6Smq7Ti8jQ0=";
        allowedIPs = [ "${cascade.addrs.cv.saelli}/128" ];
        persistentKeepalive = 25;
      }
      {
        publicKey = "ah856MqtJfCOeg4y7xl1jxcyioGC2cojVBeU047wwVU=";
        allowedIPs = [ "${cascade.addrs.cv.motog5}/128" ];
        persistentKeepalive = 25;
      }
    ];
  };
  networking.firewall.allowedUDPPorts = [ cascade.vpn.port ];
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = true;
}
