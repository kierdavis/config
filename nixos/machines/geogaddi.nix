# Geogaddi is a docker container hosting network shares and other services.
# It is named after the album "Geogaddi" by "Boards of Canada".

let
  nfsServer = { config, lib, pkgs, ... }: {
    fileSystems."/net/geogaddi" = {
      device = "/nonvolatile/shares";
      options = [ "bind" ];
    };
    services.nfs.server = {
      enable = true;
      createMountPoints = true;
      exports = ''
        /net/geogaddi 10.99.0.0/16(ro,all_squash,anonuid=1001,anongid=100)
      '';
    };
    machine.mountGeogaddiShares = false; # Don't start the NFS client.
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/docker.nix
    ../extras/headless.nix
    nfsServer
  ];

  machine = {
    name = "geogaddi";
    wifi = false;

    cpu = {
      cores = 8;
    };

    sshHostKey = ../../secret/geogaddi-ssh-host-key.priv;
  };

  networking.hostId = "62b585a5";

  campanella-vpn.client = {
    enable = true;
    certFile = "/nonvolatile/geogaddi.crt";
    keyFile = "/nonvolatile/geogaddi.key";
  };

  # Match my UID on the host system.
  users.users.kier.uid = lib.mkForce 1001;
}
