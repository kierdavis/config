with import <nixpkgs> {};

let
  network = import ./network.nix;
  vpnKeys = import ./secret/vpn-keys.nix;

  things = rec {
    vpnServerInterfaceConfig = writeText "vpn-server-wg0.conf" ''
      [Interface]
      Address = ${network.dns."vpn.vpn-server.k8s.cascade".address}/24
      PrivateKey = ${vpnKeys.server.priv}
      ListenPort = 5555
      [Peer]
      PublicKey = ${vpnKeys.saelli.pub}
      AllowedIPs = ${network.dns."vpn.saelli.cascade".address}/32
    '';

    vpnServerConfigYaml = namespace: runCommand "${namespace}.vpn-server-config.yaml" {} ''
      cat >$out <<EOF
      apiVersion: v1
      kind: Secret
      metadata:
        name: vpn-server-config
        namespace: ${namespace}
      type: Opaque
      data:
        wg0.conf: $(base64 --wrap=0 < ${vpnServerInterfaceConfig})
      EOF
    '';

    namespaces = [ "kier" "kier-dev" ];
    namespacedYamls = [ vpnServerConfigYaml ];
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
