{ config, pkgs, lib, ... }:

let
  name = config.networking.hostName;

  systemBuild = config.system.build.toplevel;
  init = "${systemBuild}/init";

  imageName = "nixos-${name}";
  imageTag = "latest";
  image = pkgs.dockerTools.buildImage {
    name = imageName;
    tag = imageTag;
    config = {
      Entrypoint = [ init ];
      Env = [ "container=1" ];
    };
  };

  containerName = name;
  hostFlags = lib.mapAttrsToList (name: addr: "--add-host=${name}:${addr}") (import ../../hosts.nix {}).hosts;
  runFlags = [
    # Give init script permission to mount filesystems.
    "--cap-add=SYS_ADMIN"
    # Give openvpn permission to configure network interfaces.
    "--cap-add=NET_ADMIN"
    "--device=/dev/net/tun"
    # Required to stop systemd hanging on startup.
    "--volume=/sys/fs/cgroup:/sys/fs/cgroup:ro"
    # Mount non-volatile data store.
    "--volume=$HOME/geogaddi:/nonvolatile"
    # Set hostname.
    "--hostname=${name}"
  ] ++ hostFlags;
  runFlagsStr = lib.concatStringsSep " " runFlags;

  unitName = "${name}.service";
  remoteScript = pkgs.writeScript "deploy-${name}-remote-script" ''
    set -o errexit -o pipefail -o nounset

    echo "** Stopping unit if it is running..."
    systemctl --user stop ${unitName} || true

    echo "** Refreshing unit file..."
    unit_dir=$HOME/.config/systemd/user
    mkdir -p $unit_dir
    cat > $unit_dir/${unitName} << EOF
      [Service]
      Type=simple
      ExecStartPre=-/usr/bin/docker kill ${containerName}
      ExecStartPre=-/usr/bin/docker rm --force ${containerName}
      ExecStart=/usr/bin/docker run --name=${containerName} ${runFlagsStr} ${imageName}:${imageTag}
      ExecStop=/usr/bin/docker stop ${containerName}
      ExecStopPost=/usr/bin/docker rm --force ${containerName}
      Restart=on-abnormal
      [Install]
      WantedBy=default.target
    EOF
    systemctl --user daemon-reload

    echo "** Starting unit..."
    systemctl --user start ${unitName}
  '';

  deployScript = pkgs.writeScriptBin "deploy-${name}" ''
    #!${pkgs.stdenv.shell}
    set -o errexit -o pipefail -o nounset

    remote=''${1:-}
    if [ -z "$remote" ]; then
      echo >&2 "usage: $0 <remote-address>"
      exit 1
    fi

    echo "* Uploading image to $remote..."
    ${pkgs.pv}/bin/pv ${image} | ${pkgs.openssh}/bin/ssh $remote docker load

    echo "* Executing deployment script on $remote..."
    ${pkgs.openssh}/bin/ssh $remote bash < ${remoteScript}
  '';

in {
  system.build.docker = {
    inherit image deployScript;
  };

  boot.isContainer = true;

  # Falls over when started, and not really necessary
  # anyway since we're isolated from the outside world.
  networking.firewall.enable = lib.mkForce false;

  fileSystems."/home" = {
    device = "/nonvolatile/home";
    options = [ "bind" ];
  };
}
