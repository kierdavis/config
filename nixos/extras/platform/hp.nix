# Add baseline from URL: http://downloads.linux.hpe.com/SDR/repo/spp-gen8/2017.04.0/hp/swpackages/bp002933.xml

{ config, lib, pkgs, ... }: let
  packages = [
    (pkgs.fetchurl {
      url = "https://cbs.centos.org/kojifiles/packages/dumb-init/1.1.3/17.el7/x86_64/dumb-init-1.1.3-17.el7.x86_64.rpm";
      hash = "sha256:0d8wszhyi5x9gj8lc7bkrvlcah8b2hm2zh8jvdby4wjgfr930fzx";
    })
    (pkgs.fetchurl {
      url = "mirror://centos/7.9.2009/updates/x86_64/Packages/dmidecode-3.2-5.el7_9.1.x86_64.rpm";
      hash = "sha256:0p79qfmxcwb9gx5d6ippz9xlxwxbz9f7q7y3fzjc4dkgfsbjr0bv";
    })
    (pkgs.fetchurl {
      url = "mirror://centos/7.9.2009/os/x86_64/Packages/hwdata-0.252-9.7.el7.x86_64.rpm";
      hash = "sha256:1n8xrxjxgmdvq08jw2g9zry3yb6pnp0fwvmnr1c8rai0wf0kg3sg";
    })
    (pkgs.fetchurl {
      url = "mirror://centos/7.9.2009/os/x86_64/Packages/libxslt-1.1.28-6.el7.x86_64.rpm";
      hash = "sha256:0hvm2mxd6phvrccs7h7mrqbsx10xafcfpsm30sl6i5lkg82nd1ln";
    })
    (pkgs.fetchurl {
      url = "mirror://centos/7.9.2009/os/x86_64/Packages/pciutils-3.5.1-3.el7.x86_64.rpm";
      hash = "sha256:1zlxphrpghsn80f8rzzh3ldgdn2zw3cg1qn3nh1ak16vmbr4jny4";
    })
    (pkgs.fetchurl {
      url = "mirror://centos/7.9.2009/os/x86_64/Packages/pciutils-libs-3.5.1-3.el7.x86_64.rpm";
      hash = "sha256:0k03w821wdwd758p3qanada2x9kp58zgvz3l0m5j4mfajdf3kw9m";
    })
    (pkgs.fetchurl {
      url = "mirror://centos/7.9.2009/os/x86_64/Packages/unzip-6.0-21.el7.x86_64.rpm";
      hash = "sha256:1av1j0cciqm3caja6rc381pg04wx76flyb3p2bilfvsabj4b8aql";
    })
    (pkgs.fetchurl {
      url = "mirror://centos/7.9.2009/os/x86_64/Packages/which-2.20-7.el7.x86_64.rpm";
      hash = "sha256:0hjpv5wmf5lzsvp80q95mmvyzycg1cc31pmda1wchji7id1q7wvc";
    })
    (pkgs.fetchurl {
      # https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_846d6e6dad2441488ce102cb9a
      url = "https://downloads.hpe.com/pub/softlib2/software1/pubsw-linux/p1216536599/v133810/rhel7/x86_64/sum-8.1.0-14.rhel7.x86_64.rpm";
      hash = "sha256:164bd4a13ce39bd9f461ef7b6e1b1b6b909cf95db77731bf8b86602ef8a18b01";
    })
  ];
  image = pkgs.dockerTools.buildImage {
    name = "hpsum";
    tag = "latest";
    fromImage = pkgs.dockerTools.pullImage {
      imageName = "docker.io/library/centos";
      imageDigest = "sha256:e4ca2ed0202e76be184e75fb26d14bf974193579039d5573fb2348664deef76e";
      sha256 = "1f0nri9aggnjgcr1ik1ca1n6al0wyjw087lfcqi8nxaylph88x97";
    };
    runAsRoot = ''
      yum install --assumeyes ${builtins.concatStringsSep " " packages}
      ln -s /bin/true /bin/firefox
    '';
    config = {
      Entrypoint = ["/bin/dumb-init"];
      Cmd = ["/bin/bash"];
    };
  };
  # baseline = pkgs.fetchzip {
  #   # https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_f9e98ba6a3b9460d987095831d
  #   url = "https://downloads.hpe.com/pub/softlib2/software1/supportpack-generic/p157293194/v123101/supspp-2016.10.rhel7.3.en.tar.gz";
  #   hash = "sha256:1njg0imr0vwi3z8iax4xvqj6aksk652mdv825nhlnimpx47kirxv";
  #   stripRoot = false;
  # };
  # components = pkgs.linkFarm "components" (builtins.map (pkg: { inherit (pkg) name; path = pkg; }) [
  #   (pkgs.fetchurl {
  #     # https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_7add8906345a4e7f982bd39f31
  #     url = "https://downloads.hpe.com/pub/softlib2/software1/sc-linux-fw-sys/p244945965/v167882/RPMS/i386/firmware-system-p73-2019.05.24-1.1.i386.rpm";
  #     hash = "sha256:0w8zd8g3jmzkxi0i52yfnxiib7rm9yic3hrqdj6377i07hdpzc6j";
  #   })
  # ]);
  cfg = config.services.hpsum;
in {
  options = with lib; {
    services.hpsum = {
      bindAddress = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Address on which HP Smart Update Manager should listen for connections. This must be an IP address, not a hostname.";
      };
      ports = {
        http = mkOption {
          type = types.int;
          default = 63001;
          description = "Port on which HP Smart Update Manager should listen for HTTP connections.";
        };
        https = mkOption {
          type = types.int;
          default = 63002;
          description = "Port on which HP Smart Update Manager should listen for HTTPS connections.";
        };
      };
    };
  };
  config = {
    virtualisation.oci-containers.containers.hpsum = {
      image = image.imageName;
      imageFile = image;
      workdir = "/opt/sum/bin";
      cmd = [
        "/opt/sum/bin/smartupdate"
        "--port" (builtins.toString cfg.ports.http)
        "--ssl_port" (builtins.toString cfg.ports.https)
      ];
      volumes = [
        "/var/lib/sum/baseline:/opt/sum/baseline:rw"
        "/var/log/sum:/var/log/sum:rw"
        # "${baseline}:/opt/sum/baseline:ro"
        # "${components}:/opt/sum/components:ro"
      ];
      ports = [
        "${cfg.bindAddress}:${builtins.toString cfg.ports.http}:${builtins.toString cfg.ports.http}"
        "${cfg.bindAddress}:${builtins.toString cfg.ports.https}:${builtins.toString cfg.ports.https}"
      ];
      extraOptions = [ "--privileged" ];
    };
    systemd.services."${config.virtualisation.oci-containers.backend}-hpsum" = {
      description = "HP Smart Update Manager";
      serviceConfig = {
        StandardOutput = lib.mkForce "journal";
        StandardError = lib.mkForce "journal";
        TimeoutStopSec = lib.mkForce 10;
      };
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/sum 0755 root root - -"
      "d /var/log/sum 0755 root root - -"
    ];
  };
}
