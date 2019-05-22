let
  lib = import <nixpkgs/lib>;
  filesystemsByHost = {
    cherry = [
      {
        netPath = "/net/torrents";
        realPath = "/downloads";
        nfsOptions = "ro,all_squash,anonuid=70,anongid=70";
      }
      {
        netPath = "/net/torrent-archive";
        realPath = "/srv/transmission/torrent-archive";
        nfsOptions = "ro,all_squash,anonuid=70,anongid=70";
      }
    ];
    bonito = [
      {
        netPath = "/net/archive";
        realPath = "/data/archive";
        nfsOptions = "ro,all_squash,anonuid=1000,anongid=100";
      }
      {
        netPath = "/net/images";
        realPath = "/data/images";
        nfsOptions = "ro,all_squash,anonuid=1000,anongid=100";
      }
      {
        netPath = "/net/music";
        realPath = "/data/music";
        nfsOptions = "ro,all_squash,anonuid=1000,anongid=100";
      }
    ];
  };
  mkNfsExport = filesystem: "${filesystem.netPath} fca5:cade:1::/96(${filesystem.nfsOptions})";
  mkBindMount = filesystem: {
    name = filesystem.netPath;
    value = {
      device = filesystem.realPath;
      options = [ "bind "];
    };
  };
  mkNfsMount = hostName: filesystem: {
    name = filesystem.netPath;
    value = {
      device = "${hostName}.h.cascade:${filesystem.netPath}";
      fsType = "nfs";
      options = [
        "vers=4"      # NFS version 4.
        "timeo=20"    # Timeout on requests before retransmission is attempted, in tenths of a second.
        "retrans=1"   # Number of times retransmission will be attempted before reporting failure.
        "soft"        # If all retransmissions fail, report an I/O error rather than continuing to retry forever.
        "noatime"     # Don't update file access times.
        "nodiratime"  # Don't update directory access times.
        "noauto"      # Don't mount at boot.
        "x-systemd.automount"          # Mount automatically when accessed.
        "x-systemd.idle-timeout=10min" # Unmount automatically when not used for 10 minutes.
      ];
    };
  };
  mkHostServerModule = hostName: groupFilesystems:
    { config, ... }: lib.mkIf config.machine.netfs."${hostName}".isServer {
      services.nfs.server = {
        enable = true;
        exports = lib.concatMapStringsSep "\n" mkNfsExport groupFilesystems;
      };
      networking.firewall.allowedTCPPorts = [ 2049 ];
      fileSystems = builtins.listToAttrs (map mkBindMount groupFilesystems);
    };
  mkHostClientModule = hostName: groupFilesystems:
    { config, ... }: lib.mkIf (!config.machine.netfs."${hostName}".isServer) {
      fileSystems = builtins.listToAttrs (map (mkNfsMount hostName) groupFilesystems);
    };

in {
  imports = lib.mapAttrsToList mkHostServerModule filesystemsByHost
    ++ lib.mapAttrsToList mkHostClientModule filesystemsByHost;

  options.machine.netfs = lib.mapAttrs (hostName: _: {
    isServer = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = ''Whether to serve the network filesystems in the "${hostName}" group, as opposed to being a client for them.'';
    };
  }) filesystemsByHost;
}
