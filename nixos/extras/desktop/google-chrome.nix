{ config, lib, pkgs, ... }: {
  programs.chromium.enable = true;
  environment.systemPackages = [ pkgs.google-chrome ];

  # Hack to make Google Chrome send DNS AAAA queries in addition to A queries even if the machine has no IPv6 internet connection.
  #networking.interfaces.lo.ipv6.routes = lib.optional (!config.machine.ipv6-internet) {
  #  address = "2001:4860:4860::8888";
  #  prefixLength = 128;
  #};
}
