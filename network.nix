let
  lib = (import <nixpkgs> {}).lib;

  mkA = name: address: { type = "A"; inherit name address; };
  mkAAAA = name: address: { type = "AAAA"; inherit name address; };
  mkCNAME = name: targetName: { type = "CNAME"; inherit name targetName; };
  mkNet = name: address: prefixLength: {
    type = "net";
    inherit name address prefixLength;
    cidr = "${address}/${builtins.toString prefixLength}";
  };

in rec {
  records = [
    # Public address space
    (mkA "pub4.beagle2.cascade" "176.9.121.81")

    # Kubenetes VPN address space
    (mkNet "k8s.network.cascade" "172.27.0.0" 16)
    (mkA "k8s.beagle2.cascade" "172.27.0.1")
    (mkA "k8s.saelli.cascade" "172.27.128.1")
    (mkA "k8s.coloris.cascade" "172.27.128.2")
    (mkA "k8s.pixel4-202007.cascade" "172.27.128.3")
    (mkA "k8s.coloris-win.cascade" "172.27.128.4")

    # Aliases to default interfaces.
  ];

  byName = builtins.listToAttrs (map (record: { name = record.name; value = record; }) records);
}
