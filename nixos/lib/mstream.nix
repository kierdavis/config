{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mstream;
  pkg = pkgs.mstream;

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
  };

  config = mkIf cfg.enable {
    users.users.mstream = {
      createHome = false;
      description = "mStream music streaming server";
      home = cfg.dataDir;
      isSystemUser = true;
    };

    systemd.services.mstream = {
      description = "mStream music streaming server";
      after = [ "network.target" "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        for dir in ${cfg.musicDir} ${cfg.dataDir}; do
          if [ ! -d $dir ]; then
            mkdir -p $dir
            chown mstream $dir
          fi
       done
      '';
      script = ''
        ${pkg}/bin/mstream --musicdir ${cfg.musicDir} --database ${cfg.dataDir}/mstream.db
      '';
      serviceConfig = {
        PermissionsStartOnly = true;
        User = "mstream";
      };
    };
  };
}
