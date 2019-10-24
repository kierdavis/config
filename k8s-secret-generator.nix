with import <nixpkgs> {};

let
  network = import ./network.nix;
  vpnKeys = import ./secret/vpn-keys.nix;

  mkYamlVal = value: if value ? fromFile then
    "$(base64 --wrap=0 <${value.fromFile})"
  else
    abort "secret value must define fromFile";

  mkYaml = { name, entries }: namespace: runCommand "${namespace}.${name}.yaml" {} ''
    cat >$out <<EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${name}
      namespace: ${namespace}
    type: Opaque
    data:
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "  ${name}: ${mkYamlVal value}") entries)}
    EOF
  '';

  things = rec {
    ingressAuthYaml = mkYaml {
      name = "ingress-auth";
      entries = {
        "auth".fromFile = ./secret/k8s-ingress.auth;
      };
    };

    vpnServerInterfaceConfig = writeText "vpn-server-wg0.conf" ''
      [Interface]
      Address = ${network.byName."vpn.vpn-server.k8s.cascade".address}/24
      PrivateKey = ${vpnKeys.server.priv}
      ListenPort = 5555
      [Peer]
      PublicKey = ${vpnKeys.saelli.pub}
      AllowedIPs = ${network.byName."vpn.saelli.cascade".address}/32
    '';

    vpnServerConfigYaml = mkYaml {
      name = "vpn-server-config";
      entries = {
        "wg0.conf".fromFile = vpnServerInterfaceConfig;
      };
    };

    namespaces = [ "kier" "kier-dev" ];
    namespacedYamls = [ ingressAuthYaml vpnServerConfigYaml ];
    yamls = lib.concatMap (yamlFunc: map (namespace: yamlFunc namespace) namespaces) namespacedYamls;
    combinedYaml = runCommand "k8s-secret-yamls" {} ''
      for file in ${lib.concatStringsSep " " yamls}; do
        cat $file >> $out
        echo '---' >> $out
      done
    '';

    syncScript = writeShellScript "sync-k8s-secrets" ''
      exec ${kubectl}/bin/kubectl apply -f ${combinedYaml}
    '';
  };

in things.syncScript // things
