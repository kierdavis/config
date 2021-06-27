# google chrome ignore /etc/hosts, so provide hist domains using a local DNS server instead.

{ config, lib, pkgs, ... }: {
  services.coredns.enable = true;
  services.coredns.config = ''
    hist {
      errors
      bind 127.0.0.1
      reload

      cancel
      loop

      chaos
      hosts
    }
  '';
  systemd.services.coredns = {
    postStart = "echo nameserver 127.0.0.1 | resolvconf -a local -m 1";
    preStop = "resolvconf -d local";
  };
}
