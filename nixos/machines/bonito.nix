let
  cascade = import ../cascade.nix;

  print-server = { config, lib, pkgs, ... }: {
    services.printing = {
      enable = true;
      drivers = [ pkgs.samsung-unified-linux-driver_4_01_17 ];
      extraConf = ''
        ServerName bonito.h.cascade
        ServerAlias print.cascade
      '';
    };
    networking.firewall.allowedTCPPorts = [ 631 ];
    environment.variables.CUPS_SERVER = lib.mkForce ""; # override common/print.nix
  };

  http-server = { config, lib, pkgs, ... }: {
    services.nginx = {
      enable = true;
      virtualHosts = {
      };
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };

  mysql-server = { config, lib, pkgs, ... }: {
    services.mysql = {
      enable = true;
      dataDir = "/srv/mysql";
      package = pkgs.mysql;
      bind = "127.0.0.1";
      port = 3306;
    };
    networking.firewall.allowedTCPPorts = [ 3306 ];
  };

  wiki-server = { config, lib, pkgs, ... }: {
    services.gollum = {
      enable = true;
      address = cascade.hostAddrs.bonito;
      stateDir = "/srv/gollum/content";
    };
    networking.firewall.allowedTCPPorts = [ 4567 ];
    users.users.gollum.home = "/srv/gollum";
  };

  music-server = { config, lib, pkgs, ... }: {
    imports = [ ../lib/mstream.nix ];
    services.mstream = {
      enable = true;
      musicDir = "/data/music/library";
      dataDir = "/srv/mstream";
      lastfm = {
        username = "kierdavis";
        password = (import ../../secret/passwords.nix).lastfm;
      };
      ssl = {
        certFile = ../../secret/ssl/bonito-mstream.crt;
        keyFile = ../../secret/ssl/bonito-mstream.key;
      };
    };
    networking.firewall.allowedTCPPorts = [ 3000 ];
    environment.systemPackages = with pkgs; [ beets youtube-dl ];
  };

  minecraft-server = { config, lib, pkgs, ... }: let
    template = pkgs.fetchzip {
      url = "https://media.forgecdn.net/files/2714/58/FTBUltimateReloadedServer_1.7.1.zip";
      name = "ftb-ultimate-reloaded-server";
      stripRoot = false;
      sha256 = "0nkdrycwjjlc86f1100lqc87d3lf2s0aaa3knczlry5dmbawfahj";
    };
    jarName = "FTBserver-1.12.2-14.23.5.2836-universal.jar";
    stampName = ".installed";
    startScript = pkgs.writeShellScriptBin "minecraft-server" ''
      set -o errexit -o nounset
      if [ ! -e ${stampName} ]; then
        ${pkgs.rsync}/bin/rsync -rl ${template}/ ./
        chmod -R +w .
        chmod +x FTBInstall.sh
        PATH=${pkgs.which}/bin:${pkgs.curl}/bin:$PATH ./FTBInstall.sh
        touch ${stampName}
      fi
      exec ${pkgs.jre}/bin/java "$@" -jar ${jarName} nogui
    '';
  in {
    services.minecraft-server = {
      dataDir = "/srv/minecraft/aqua";
      declarative = true;
      enable = true;
      eula = true;
      jvmOpts = "-Xmx4096M -Xms4096M";
      openFirewall = true;
      package = startScript;
      serverProperties = {
        allow-flight = false;
        allow-nether = true;
        difficulty = "normal";
        enable-command-block = true;
        enable-query = false;
        enable-rcon = false;
        force-gamemode = false;
        gamemode = "survival";
        generate-structures = true;
        hardcore = false;
        level-name = "world";
        level-seed = "";
        max-players = 20;
        motd = "no u";
        online-mode = true;
        prevent-proxy-connections = false;
        pvp = false;
        server-ip = "";
        server-port = 25565;
        snooper-enabled = false;
        spawn-animals = true;
        spawn-monsters = true;
        spawn-npcs = true;
        spawn-protection = 0;
        white-list = false;
        enforce-whitelist = false;
      };
      whitelist = {};
    };
  };

in { config, lib, pkgs, ... }: {
  imports = [
    ../common
    ../extras/platform/proxmox-ct.nix
    ../extras/headless.nix
    print-server
    http-server
    mysql-server
    wiki-server
    music-server
    minecraft-server
  ];

  # High-level configuration used by nixos/common/*.nix.
  machine = {
    name = "bonito";
    wifi = false;
    ipv6-internet = false;
    cpu = {
      cores = 24;
      intel = true;
    };
    netfs.bonito.isServer = true;
  };

  # Make sure to generate a new ID using:
  #   head -c4 /dev/urandom | od -A none -t x4
  # if this config is used as a reference for a new host!
  networking.hostId = "00e60dbb";

  networking.useDHCP = false;
  networking.interfaces.eth0 = {
    useDHCP = false;
    ipv4.addresses = [ { address = cascade.addrs.cl4.bonito; prefixLength = 24; } ];
    ipv6.addresses = [ { address = cascade.addrs.cl.bonito; prefixLength = 112; } ];
  };
  networking.defaultGateway = {
    address = cascade.addrs.cl4.altusanima;
    interface = "eth0";
  };
  networking.defaultGateway6 = {
    address = cascade.addrs.cl.altusanima;
    interface = "eth0";
  };
}
