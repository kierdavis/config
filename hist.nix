let
  lib = import <nixpkgs/lib>;

  withCIDR6 = network: network // {
    cidr = "${network.prefix}::/${builtins.toString network.prefixLength}";
  };
  withCIDR4 = network: network // {
    cidr = "${network.prefix}.0/${builtins.toString network.prefixLength}";
  };

in rec {
  wgPort = 9509;
  upstreamNameServers = [ "1.1.1.1" "1.0.0.1" ];

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
      prefix = "192.168.102";
      prefixLength = 24;
      mask = "255.255.255.0"; # TODO: easy way to compute this from prefixLength?
      dhcp = {
        first = "${prefix}.20";
        last = "${prefix}.254";
      };
    };
    pointToPoint = withCIDR4 rec {
      prefix = "192.168.103";
      prefixLength = 24;
      mask = "255.255.255.0"; # TODO: easy way to compute this from prefixLength?
    };
  };

  hosts = {
    ptolemy = {
      addresses = rec {
        wg = "${networks.wg.prefix}::1";
        ptolemyGuests = "${networks.ptolemyGuests.prefix}::1";
        ptolemyGuests4 = "${networks.ptolemyGuests4.prefix}.1";
        default.public = "192.168.1.27";  # Hack until installed in DC.
        default.private = wg;
      };
      wgGatewayTo = [
        networks.ptolemyGuests.cidr
        networks.ptolemyGuests4.cidr
      ];
      publicKey = "fUn4jHh1QLmuGZ1qNMI0nPMXAfqos7xMMTzFQHDw/0Q=";
    };
    fingerbib = {
      addresses = rec {
        wg = "${networks.wg.prefix}::3";
        default.public = "192.168.178.34";
        default.private = wg;
      };
      publicKey = "s3AsWEhK5Zp+YIoWYIm/p2ESquPS7h3OSKQ7SXeIElg=";
      virtualHosts = [ "plex" "transmission" ];
    };
    coloris = {
      addresses = rec {
        wg = "${networks.wg.prefix}::2";
        default.private = wg;
      };
      publicKey = "1cxw/cG2D/+VDtb65q/R3H5XfIQr/k820+8Uz4Vqvz8=";
    };
    saelli = {
      addresses = rec {
        wg = "${networks.wg.prefix}::4";
        default.private = wg;
      };
      publicKey = "mjplz2S5i8HvSFOVSyYpn6SLLipMWMGGf08Ld1VP3U8=";
    };
  };

  dns =	let
    defaultEntryForHost = hostName: hostData: [{ name = hostName; address = hostData.addresses.default.private; }];
    virtualEntriesForHost = hostName: hostData: builtins.map (name: { inherit name; address = hostData.addresses.default.private; }) (hostData.virtualHosts or []);
    interfaceEntriesForHost = hostName: hostData: lib.mapAttrsToList (intfName: address: { name = "${intfName}.${hostName}"; inherit address; }) (removeAttrs hostData.addresses ["default"]);
    entriesForHost = hostName: hostData: lib.concatMap (fun: fun hostName hostData) [defaultEntryForHost virtualEntriesForHost interfaceEntriesForHost];
    entriesForHosts = lib.flatten (lib.mapAttrsToList entriesForHost hosts);
    entries = entriesForHosts;
    appendDomain = entry: entry // { name = "${entry.name}.hist"; };
  in lib.concatMap (entry: [(appendDomain entry) entry]) entries;
}
