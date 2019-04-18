rec {
  addr = "fca5:cade:1::";
  vpnPort = 9045;
  hosts = {
    altusanima = rec {
      addrs.vpn = "fca5:cade:1::1:2";
      addrs.vlan = "fca5:cade:1::2:1";
      addrs.sslom = "fca5:cade:1::3:1";
      vpnPeerInfo = {
        publicKey = "jbol9385zdX7Ctfd3iz1LM3pHbT/zB1YvRg6gMx/zV8=";
        allowedIPs = [
          "${addrs.vpn}/128"
          "${addrs.vlan}/112"
          "${addrs.sslom}/112"
        ];
        persistentKeepalive = 25;
      };
    };
    bonito = {
      addrs.vlan = "fca5:cade:1::2:4";
    };
    campanella2 = rec {
      addrs.public = "80.85.84.13";
      addrs.vpn = "fca5:cade:1::1:1";
      vpnPeerInfo = {
        publicKey = "rCt64U6gNe10TK7SRhaNd/ePuzhiLKW2IAJKSHTQKE4=";
        endpoint = "${addrs.public}:${toString vpnPort}";
        allowedIPs = [ "${addrs.vpn}/112" ];
        persistentKeepalive = 25;
      };
    };
    saelli = rec {
      addrs.vpn = "fca5:cade:1::1:3";
      vpnPeerInfo = {
        publicKey = "Kk29EQEXWlCJxMB14brjEz4/UOixlXPp6Smq7Ti8jQ0=";
        allowedIPs = [ "${addrs.vpn}/128" ];
        persistentKeepalive = 25;
      };
    };
    shadowshow = {
      addrs.lom = "fca5:cade:1::3:2";
    };
  };
}
