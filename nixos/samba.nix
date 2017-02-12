let
  secrets = import ./secrets.nix;

  credentials = {
    user = "kier";
    pass = secrets.sambaPassword;
  };
in

rec {
  shares = {
    music = {
      comment = "Music";
      writeable = true;
    };
    documents = {
      comment = "Documents";
      writeable = true;
    };
    torrents = {
      comment = "Torrent downloads";
      writeable = false;
    };
    archive = {
      comment = "Archive";
      writeable = true;
    };
    misc = {
      comment = "Miscellaneous";
      writeable = true;
    };
 };

  server = { config, lib, pkgs, ... }: {
    networking.firewall.allowedTCPPorts = [ 445 ];
    services.samba = {
      enable = true;
      shares = lib.mapAttrs (name: share: share // {
        path = "/shares/${name}";
        browseable = true;
        "valid users" = [credentials.user];
      }) shares;
    };
    fileSystems = lib.mapAttrs (name: share: {
      mountPoint = "/mnt/nocturn/${name}";
      device = "/shares/${name}";
      options = ["bind"];
    }) shares;
  };

  client =
    { host, port, selectedShares ? shares }:
    { config, lib, pkgs, ... }:
    let
      credentialsFile = pkgs.writeText "samba-credentials" ''
        username=${credentials.user}
        password=${credentials.pass}
        domain=WORKGROUP
      '';
    in {
      fileSystems = lib.mapAttrs (name: share: {
        mountPoint = "/mnt/nocturn/${name}";
        device = "//${host}/${name}";
        fsType = "cifs";
        options = [
          "credentials=${credentialsFile}" # file containing the username/password for login
          "port=${toString port}"          # which port on the host to connect to
          "noauto"                         # don't mount at boot
          "x-systemd.automount"            # mount automatically when accessed
          "x-systemd.idle-timeout=10min"   # unmount automatically when not used for 10 minutes
        ];
      }) selectedShares;
    };
}
