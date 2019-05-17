let
  lib = import <nixpkgs/lib>;
in rec {
  ipPrefix = "fca5:cade:1";
  addrs = {
    pub = { # public
      campanella2 = "2a01:7e00::f03c:91ff:fe77:738c";
      beagle2 = "2a01:4f8:151:8047::2";
    };
    pub4 = {
      campanella2 = "80.85.84.13";
      beagle2 = "176.9.121.81";
    };
    cv = { # cascade VPN
      campanella2 = "${ipPrefix}::1:1";
      altusanima = "${ipPrefix}::1:2";
      saelli = "${ipPrefix}::1:3";
      motog5 = "${ipPrefix}::1:4";
    };
    cl = { # cascade LAN at woodside road
      altusanima = "${ipPrefix}::2:1";
      # altusanima-lom = "${ipPrefix}::2:2";
      shadowshow = "${ipPrefix}::2:3";
      # shadowshow-lom = "${ipPrefix}::2:4";
      bonito = "${ipPrefix}::2:5";
      cherry = "${ipPrefix}::2:6";
    };
    cl4 = {
      altusanima = "192.168.2.1";
      # altusanima-lom = "192.168.2.2";
      shadowshow = "192.168.2.3";
      # shadowshow-lom = "192.168.2.4";
      bonito = "192.168.2.5";
      cherry = "192.168.2.6";
    };
    cvl = { # cascade VLAN at woodside road
      altusanima = "${ipPrefix}::3:1";
      coloris = "${ipPrefix}::3:2";
    };
    c2vpn = { # legacy campanella2 vpn
      campanella2 = "10.99.0.1";
      coloris = "10.99.1.1";
      ouroboros = "10.99.1.2";
      bonito = "10.99.1.3";
      saelli = "10.99.1.4";
      cherry = "10.99.1.7";
    };
  };
  hostAddrs = {
    inherit (addrs.cv) campanella2 altusanima saelli motog5;
    inherit (addrs.cl) shadowshow bonito cherry;
    inherit (addrs.cvl) coloris;
  };
  domainNames = lib.flatten [
    (lib.mapAttrsToList
      (segName: segAddrs: lib.mapAttrsToList
        (hostName: addr: {
          name = "${hostName}.${segName}.s.cascade";
          inherit addr;
        })
        segAddrs
      )
      addrs
    )
    (lib.mapAttrsToList
      (hostName: addr: {
        name = "${hostName}.h.cascade";
        inherit addr;
      })
      hostAddrs
    )
  ];
  vpn.port = 9045;
  vpn.peers = let
    mkEndpoint = host: "${host}:${toString vpn.port}";
    mkPeer = attrs: attrs // {
      persistentKeepalive = 25;
    };
  in {
    campanella2 = mkPeer {
      publicKey = "rCt64U6gNe10TK7SRhaNd/ePuzhiLKW2IAJKSHTQKE4=";
      allowedIPs = [ "${addrs.cv.campanella2}/96" ];
      endpoint = mkEndpoint addrs.pub4.campanella2;
    };
    altusanima = mkPeer {
      publicKey = "jbol9385zdX7Ctfd3iz1LM3pHbT/zB1YvRg6gMx/zV8=";
      allowedIPs = [
        "${addrs.cv.altusanima}/128"
        "${addrs.cl.altusanima}/112"
        "${addrs.cvl.altusanima}/112"
      ];
    };
    saelli = mkPeer {
      publicKey = "Kk29EQEXWlCJxMB14brjEz4/UOixlXPp6Smq7Ti8jQ0=";
      allowedIPs = [ "${addrs.cv.saelli}/128" ];
    };
    motog5 = mkPeer {
      publicKey = "ah856MqtJfCOeg4y7xl1jxcyioGC2cojVBeU047wwVU=";
      allowedIPs = [ "${addrs.cv.motog5}/128" ];
    };
  };
  upstreamNameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
