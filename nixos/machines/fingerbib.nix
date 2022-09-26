let
  passwords = import ../../secret/passwords.nix;

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

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/grub.nix
    webServer
    mediaServer
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
  users.users.jellyfin.extraGroups = ["media"];

  # Allow media user to create hardlinks to files owned by transmission.
  boot.kernel.sysctl."fs.protected_hardlinks" = 0;
}
