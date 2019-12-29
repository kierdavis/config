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
    (mkNet "k8s-vpn.network.cascade" "10.107.252.0" 24)
    (mkA "k8s-vpn.beagle2.cascade" "10.107.252.1")
    (mkA "k8s-vpn.butterfly.cascade" "10.107.252.2")

    # Aliases to default interfaces.
  ];

  byName = builtins.listToAttrs (map (record: { name = record.name; value = record; }) records);

  # OpenDNS
  upstreamNameservers = [ "208.67.222.222" "208.67.220.220" ];
}
