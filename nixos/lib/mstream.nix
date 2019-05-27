{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mstream;
  pkg = pkgs.mstream;

  command = escapeShellArgs (
    [
      "${pkg}/bin/mstream"
      "--musicdir"
      cfg.musicDir
    ]
    ++ lib.optionals (cfg.lastfm.username != null) [ "--luser" cfg.lastfm.username ]
    ++ lib.optionals (cfg.lastfm.password != null) [ "--lpass" cfg.lastfm.password ]
    ++ lib.optionals (cfg.ssl.certFile != null) [ "--cert" cfg.ssl.certFile ]
    ++ lib.optionals (cfg.ssl.keyFile != null) [ "--key" cfg.ssl.keyFile ]
  );

in {
  options.services.mstream = {
    enable = mkEnableOption "mstream";

    musicDir = mkOption {
      type = types.path;
      default = "/var/lib/mstream/library";
      description = ''
        The location of the music library to serve.
      '';
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/mstream";
      description = ''
        The location of the server data directory (including the music metadata database).
      '';
    };

    lastfm.username = mkOption {
      type = types.string;
      default = null;
      description = ''
        Last.fm username.
      '';
    };

    lastfm.password = mkOption {
      type = types.string;
      default = null;
      description = ''
        Last.fm password. This will be passed on the command line and so will be visible to all other users on the system! This needs to be fixed upstream.
      '';
    };

    ssl.certFile = mkOption {
      type = types.path;
      default = null;
      description = ''
        SSL certificate file.
      '';
    };

    ssl.keyFile = mkOption {
      type = types.path;
      default = null;
      description = ''
        SSL private key file.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.mstream = {
      createHome = false;
      description = "mStream music streaming server";
      home = cfg.dataDir;
      isSystemUser = true;
    };

    users.groups.mstream = {
      members = [ "mstream" "kier" ];
    };

    systemd.services.mstream = {
      description = "mStream music streaming server";
      after = [ "network.target" "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        for dir in ${cfg.musicDir} ${cfg.dataDir}/{image-cache,save/db,save/logs}; do
          if [ ! -d $dir ]; then
            mkdir -p $dir
            chown mstream:mstream $dir
          fi
       done
      '';
      script = "exec ${command}";
      serviceConfig = {
        PermissionsStartOnly = true;
        User = "mstream";
        WorkingDirectory = cfg.dataDir;
      };
    };
  };
}
