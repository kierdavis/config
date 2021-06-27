{ config, lib, pkgs, ... }: {
  programs.chromium.enable = true;
  environment.systemPackages = [ pkgs.google-chrome ];

  # Google Chrome ignore /etc/hosts, so provide hist domains using a local DNS server instead.
  environment.etc."resolv.conf".text = "nameserver 127.0.0.1";
  services.coredns.enable = true;
  services.coredns.config = ''
    hist {
      bind 127.0.0.1
      errors
      log
      reload
      cancel
      loop
      hosts
    }
    . {
      bind 127.0.0.1
      errors
      log
      reload
      cancel
      loop
      forward . /etc/resolv.conf.upstream
    }
  '';
  networking.resolvconf.extraConfig = "resolv_conf=/etc/resolv.conf.upstream";

  # Hack to make Google Chrome send DNS AAAA queries in addition to A queries even if the machine has no IPv6 internet connection.
  networking.interfaces.lo.ipv6.routes = lib.optional (!config.machine.ipv6-internet) {
    address = "2001:4860:4860::8888";
    prefixLength = 128;
  };
}
