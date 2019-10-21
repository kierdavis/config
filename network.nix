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

    # VPN address space
    (mkNet "vpn.network.cascade" "10.88.1.0" 24)
    (mkA "vpn.vpn-server.k8s.cascade" "10.88.1.1")
    (mkA "vpn.saelli.cascade" "10.88.1.2")

    # Aliases to default interfaces.
    (mkCNAME "saelli.cascade" "vpn.saelli.cascade")
  ];

  byName = builtins.listToAttrs (map (record: { name = record.name; value = record; }) records);

  # OpenDNS
  upstreamNameservers = [ "208.67.222.222" "208.67.220.220" ];
}
