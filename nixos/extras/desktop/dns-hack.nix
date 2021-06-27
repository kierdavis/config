# google chrome ignore /etc/hosts, so provide hist domains using a local DNS server instead.

{ config, lib, pkgs, ... }: {
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
}
