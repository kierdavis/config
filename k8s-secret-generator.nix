with import <nixpkgs> {};

let
  network = import ./network.nix;
  vpnKeys = import ./secret/vpn-keys.nix;
  passwords = import ./secret/passwords.nix;

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

    lastfmYaml = mkYaml {
      name = "lastfm";
      entries = {
        "password".fromFile = writeText "lastfm-password" passwords.lastfm;
      };
    };

    namespaces = [ "kier" "kier-dev" ];
    namespacedYamls = [ ingressAuthYaml lastfmYaml ];
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
