let
  lib = import <nixpkgs/lib>;
in rec {
  addrs = {
    pub = { # public
      campanella2 = "2a01:7e00::f03c:91ff:fe77:738c";
      beagle2 = "2a01:4f8:151:8047::2";
    };
    pub4 = {
      campanella2 = "80.85.84.13";
      beagle2 = "176.9.121.81";
    };
    w4 = { # woodside road LAN
      _subnet = "192.168.1.0";
      gateway = "192.168.1.1";
      coloris = "192.168.1.20";
      altusanima = "192.168.1.30";
    };
    cv = { # cascade VPN
      _subnet = "fca5:cade:1::1:0";
      campanella2 = "fca5:cade:1::1:1";
      altusanima = "fca5:cade:1::1:2";
      saelli = "fca5:cade:1::1:3";
      motog5 = "fca5:cade:1::1:4";
    };
    cl = { # cascade LAN at woodside road
      _subnet = "fca5:cade:1::2:0";
      altusanima = "fca5:cade:1::2:1";
      # altusanima-lom = "fca5:cade:1::2:2";
      shadowshow = "fca5:cade:1::2:3";
      # shadowshow-lom = "fca5:cade:1::2:4";
      bonito = "fca5:cade:1::2:5";
      cherry = "fca5:cade:1::2:6";
      moon = "fca5:cade:1::2:7";
    };
    cl4 = {
      _subnet = "192.168.2.0";
      altusanima = "192.168.2.1";
      # altusanima-lom = "192.168.2.2";
      shadowshow = "192.168.2.3";
      # shadowshow-lom = "192.168.2.4";
      bonito = "192.168.2.5";
      cherry = "192.168.2.6";
      moon = "192.168.2.7";
    };
    cvl = { # cascade VLAN at woodside road
      _subnet = "fca5:cade:1::3:0";
      altusanima = "fca5:cade:1::3:1";
      coloris = "fca5:cade:1::3:2";
    };
  };
  hostAddrs = {
    inherit (addrs.pub4) beagle2;
    inherit (addrs.cv) campanella2 altusanima saelli motog5;
    inherit (addrs.cl) shadowshow bonito cherry moon;
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
    { name = "virt.cascade"; addr = hostAddrs.campanella2; }
    { name = "net.cascade"; addr = hostAddrs.campanella2; }
    { name = "music.cascade"; addr = hostAddrs.campanella2; }
    { name = "wiki.cascade"; addr = hostAddrs.campanella2; }
    { name = "torrents.cascade"; addr = hostAddrs.campanella2; }
  ];
  vpn.port = 9045;
  upstreamNameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
}
