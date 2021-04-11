let
  withCIDR6 = network: network // {
    cidr = "${network.prefix}::/${builtins.toString network.prefixLength}";
  };
  withCIDR4 = network: network // {
    cidr = "${network.prefix}.0/${builtins.toString network.prefixLength}";
  };

in rec {
  wgPort = 9509;

  networks = {
    wg = withCIDR6 {
      prefix = "fdec:affb:e11e:1";
      prefixLength = 64;
    };
    ptolemyGuests = withCIDR6 {
      prefix = "fdec:affb:e11e:2";
      prefixLength = 64;
    };
    ptolemyGuests4 = withCIDR4 rec {
      prefix = "192.168.11";
      prefixLength = 24;
      mask = "255.255.255.0"; # TODO: easy way to compute this from prefixLength?
      dhcp = {
        first = "${prefix}.20";
        last = "${prefix}.254";
      };
    };
  };

  hosts = {
    ptolemy = {
      addresses = {
        wg = "${networks.wg.prefix}::1";
        ptolemyGuests = "${networks.ptolemyGuests.prefix}::1";
        ptolemyGuests4 = "${networks.ptolemyGuests4.prefix}.1";
        internet = "192.168.1.27";  # Hack until installed in DC.
      };
      wgGatewayTo = [
        networks.ptolemyGuests.cidr
        networks.ptolemyGuests4.cidr
      ];
      publicKey = "fUn4jHh1QLmuGZ1qNMI0nPMXAfqos7xMMTzFQHDw/0Q=";
    };
    coloris = {
      addresses = {
        wg = "${networks.wg.prefix}::2";
      };
      publicKey = "1cxw/cG2D/+VDtb65q/R3H5XfIQr/k820+8Uz4Vqvz8=";
    };
  };
}
