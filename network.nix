let
  mkA = address: { recordType = "A"; inherit address; };
  mkAAAA = address: { recordType = "AAAA"; inherit address; };
  mkCNAME = hostname: { recordType = "CNAME"; inherit hostname; };
  mkNet = address: prefixLength: {
    recordType = "net";
    inherit address prefixLength;
    cidr = "${address}/${builtins.toString prefixLength}";
  };

in {
  dns = rec {
    # Public address space
    "pub4.beagle2.cascade" = mkA "176.9.121.81";

    # VPN address space
    "vpn.network.cascade" = mkNet "10.88.1.0" 24;
    "vpn.vpn-server.k8s.cascade" = mkA "10.88.1.1";
    "vpn.saelli.cascade" = mkA "10.88.1.2";

    # Aliases to default interfaces.
    "saelli.cascade" = mkCNAME "vpn.saelli.cascade";
  };
}
