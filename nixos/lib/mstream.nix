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

    database = mkOption {
      type = types.path;
      default = "/var/lib/mstream/mstream.db";
      description = ''
        The location of the mstream database.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mstream = {
      description = "mStream music streaming server";
      after = [ "network.target" "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        mkdir -p ${cfg.musicDir}
        mkdir -p $(dirname ${cfg.database})
      '';
      script = ''
        ${pkg}/bin/mstream --musicdir ${cfg.musicDir} --database ${cfg.database}
      '';
      serviceConfig = {
        PermissionsStartOnly = true;
      };
    };
  };
}
