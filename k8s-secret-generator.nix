with import <nixpkgs> {};

let
  network = import ./network.nix;
  vpnKeys = import ./secret/vpn-keys.nix;

  mkYamlVal = value: if value ? filePath then
    "$(base64 --wrap=0 <${value.filePath})"
  else
    abort "secret value must define filePath";

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
        "auth".filePath = ./secret/k8s-ingress.auth;
      };
    };

    vpnServerInterfaceConfig = writeText "vpn-server-wg0.conf" ''
      [Interface]
      Address = ${network.dns."vpn.vpn-server.k8s.cascade".address}/24
      PrivateKey = ${vpnKeys.server.priv}
      ListenPort = 5555
      [Peer]
      PublicKey = ${vpnKeys.saelli.pub}
      AllowedIPs = ${network.dns."vpn.saelli.cascade".address}/32
    '';

    vpnServerConfigYaml = mkYaml {
      name = "vpn-server-config";
      entries = {
        "wg0.conf".filePath = vpnServerInterfaceConfig;
      };
    };

    namespaces = [ "kier" "kier-dev" ];
    namespacedYamls = [ ingressAuthYaml vpnServerConfigYaml ];
    yamls = lib.concatMap (yamlFunc: map (namespace: yamlFunc namespace) namespaces) namespacedYamls;
    yamlDir = runCommand "k8s-secret-yamls" {} ''
      mkdir -p $out
      ${lib.concatMapStringsSep "\n" (yaml: "ln -s ${yaml} $out/${yaml.name}") yamls}
    '';

    syncScript = writeShellScript "sync-k8s-secrets" ''
      for file in $(find ${yamlDir} -name '*.yaml'); do
        kubectl apply -f $file
      done
    '';
  };

in things.syncScript // things
