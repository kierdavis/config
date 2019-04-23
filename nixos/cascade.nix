rec {
  ipPrefix = "fca5:cade:1";
  addrs = {
    "campanella2.h.cascade" = "${ipPrefix}::1:1";
    "altusanima.h.cascade" = "${ipPrefix}::1:2";
    "saelli.h.cascade" = "${ipPrefix}::1:3";
    "motog5.h.cascade" = "${ipPrefix}::1:4";

    "lan-gw.altusanima.h.cascade" = "${ipPrefix}::2:1";
    "lom.altusanima.h.cascade" = "${ipPrefix}::2:2";
    "shadowshow.h.cascade" = "${ipPrefix}::2:3";
    "lom.shadowshow.h.cascade" = "${ipPrefix}::2:4";
    "bonito.h.cascade" = "${ipPrefix}::2:5";
    "cherry.h.cascade" = "${ipPrefix}::2:6";

    "vlan-gw.altusanima.h.cascade" = "${ipPrefix}::3:1";
    "coloris.h.cascade" = "${ipPrefix}::3:2";

    "public.campanella2.h.cascade" = "80.85.84.13";
  };
  vpn.port = 9045;
  vpn.peers = let
    mkEndpoint = host: "${host}:${toString vpn.port}";
    mkPeer = attrs: attrs // {
      persistentKeepalive = 25;
    };
  in {
    campanella2 = mkPeer {
      publicKey = "rCt64U6gNe10TK7SRhaNd/ePuzhiLKW2IAJKSHTQKE4=";
      allowedIPs = [ "${addrs."campanella2.h.cascade"}/112" ];
      endpoint = mkEndpoint addrs."public.campanella2.h.cascade";
    };
    altusanima = mkPeer {
      publicKey = "jbol9385zdX7Ctfd3iz1LM3pHbT/zB1YvRg6gMx/zV8=";
      allowedIPs = [
        "${addrs."altusanima.h.cascade"}/128"
        "${addrs."lan-gw.altusanima.h.cascade"}/112"
        "${addrs."vlan-gw.altusanima.h.cascade"}/112"
      ];
    };
    saelli = mkPeer {
      publicKey = "Kk29EQEXWlCJxMB14brjEz4/UOixlXPp6Smq7Ti8jQ0=";
      allowedIPs = [ "${addrs."saelli.h.cascade"}/128" ];
    };
  };
}
