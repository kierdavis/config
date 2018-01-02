{ pkgs ? import <nixpkgs> {} }:

let
  hosts = (import ../../../hosts.nix { inherit pkgs; }).hosts;

  vpnClientConfTemplate = ../../vpnclient.conf;
  vpnClientConf = pkgs.runCommand "client.conf" {
    remoteHost = hosts.beagle2;
    remotePort = 1194;
    caCert     = ../../../secret/pki/ca.crt;
    clientCert = ../../../secret/pki/campanella-nfsserver.crt;
    clientKey  = ../../../secret/pki/campanella-nfsserver.key;
    vpnHmacKey = ../../../secret/vpn-hmac.key;
  } "substituteAll ${vpnClientConfTemplate} $out";

  supervisorConfig = pkgs.writeText "supervisord.conf" ''
    [supervisord]
    nodaemon=true

    [program:openvpn]
    command=${pkgs.openvpn}/bin/openvpn --config ${vpnClientConf}
    redirect_stderr=true
    stdout_logfile=/dev/stdout
    stdout_logfile_maxbytes=0
    startsecs=2
    autorestart=true

    [program:nfs]
    command=/init
    redirect_stderr=true
    stdout_logfile=/dev/stdout
    stdout_logfile_maxbytes=0
    startsecs=2
    autorestart=true
  '';

  runScript = pkgs.writeScript "campanella-nfsserver-run" ''
    #!${pkgs.stdenv.shell}
    set -o errexit -o pipefail -o nounset

    echo "/export 10.99.0.0/16(rw,no_subtree_check,fsid=0,insecure)" > /etc/exports

    ${pkgs.python2Packages.supervisor}/bin/supervisord --configuration ${supervisorConfig}
  '';

  image = pkgs.dockerTools.buildImage {
    name = "campanella-nfsserver";
    tag = "latest";
    fromImage = pkgs.dockerTools.pullImage {
      imageName = "joebiellik/nfs4";
      imageTag = "latest";
      sha256 = "021fpg2anz4swlaaq1qbii95alkyzy9nlmg593c51j94ffp0knw6";
    };
    config = {
      Cmd = [ runScript ];
    };
  };

in image
