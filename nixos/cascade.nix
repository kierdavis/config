{
  port = 9045;
  addrs = {
    campanella2 = {
      public = "80.85.84.13";
      vpn = "fca5:cade:1::1:1";
    };
    altusanima = {
      vpn = "fca5:cade:1::1:2";
      vlan = "fca5:cade:1::2:1";
      sslom = "fca5:cade:1::3:1";
    };
    shadowshow_lom = {
      sslom = "fca5:cade:1::3:2";
    };
    bonito = {
      vlan = "fca5:cade:1::2:4";
    };
  };
  keys = {
    campanella2 = "rCt64U6gNe10TK7SRhaNd/ePuzhiLKW2IAJKSHTQKE4=";
    altusanima = "jbol9385zdX7Ctfd3iz1LM3pHbT/zB1YvRg6gMx/zV8=";
  };
}
