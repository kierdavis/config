{ config, pkgs, lib, ... }:

{
  networking.hostName = config.machine.name;
  networking.domain = "skaia";

  networking.iproute2.enable = true;

  # Firewall
  networking.firewall.enable = lib.mkDefault true;
  networking.firewall.allowPing = true;

  # Debugging:
  networking.firewall.logReversePathDrops = true;

  # Bluetooth
  # bluetoothctl doesn't seem to work properly on any of my machines...
  hardware.bluetooth.enable = false;

  # When forwarding a port from a host to a container using systemd-nspawn, this setting is
  # required in order to make the port accessible from other machine's on the host's network.
  # https://docs.docker.com/v17.09/engine/userguide/networking/default_network/container-communication/#communicating-to-the-outside-world
  # TODO: can probably be removed once fingerbib is killed off.
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = true;

  # resolvconf prioritises interfaces according to a metric (lower is better).
  # This metric is provided via -m or IFMETRIC when resolvconf -a is called.
  # NixOS static configuration (networking.nameservers) option has metric 1.
  # DHCP interfaces have a default metric of 1000 + if_nametoindex(3), but this can be overridden in dhcpcd.conf.
  networking.resolvconf.enable = true;
  systemd.services.fallback-dns-config = {
    inherit (config.systemd.services.network-setup) before wants partOf conflicts wantedBy;
    after = ["network-pre.target"];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    unitConfig.DefaultDependencies = false;
    script = ''
      ${pkgs.openresolv}/sbin/resolvconf -a static-fallback -m 800 <<EOF
      nameserver 1.1.1.1
      nameserver 1.0.0.1
      EOF
    '';
    preStop = ''
      ${pkgs.openresolv}/sbin/resolvconf -d static-fallback
    '';
  };

  systemd.targets.skaia-online.wantedBy = ["multi-user.target" "network-online.target"];

  systemd.services.skaia-connectivity-test = {
    wants = ["network-pre.target"];
    after = ["network-pre.target"];
    wantedBy = ["skaia-online.target"];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      for i in $(${pkgs.coreutils}/bin/seq 30); do
        if ${pkgs.curl}/bin/curl --connect-timeout 2 --insecure https://10.88.192.1/ > /dev/null; then
          exit 0
        fi
        sleep 2
      done
      echo >&2 "failed to connect to skaia"
      exit 1
    '';
  };

  systemd.services.skaia-dns-config = {
    wants = ["network-pre.target"];
    requires = ["skaia-connectivity-test.service"];
    after = ["network-pre.target" "skaia-connectivity-test.service"];
    wantedBy = ["skaia-online.target"];
    path = [ pkgs.bind.host pkgs.openresolv ];
    environment = {
      server = "10.88.219.142";
      testHost = "dns.skaia";
      resolvconfName = "skaia";
      resolvconfMetric = "400";
    };
    script = ''
      while true; do
        if host "$testHost" "$server" &>/dev/null; then
          if [[ ! -e "/run/resolvconf/interfaces/$resolvconfName" ]]; then
            echo nameserver "$server" | resolvconf -a "$resolvconfName" -m "$resolvconfMetric"
          fi
        else
          if [[ -e "/run/resolvconf/interfaces/$resolvconfName" ]]; then
            resolvconf -d "$resolvconfName"
          fi
        fi
        sleep 15
      done
    '';
    preStop = ''
      resolvconf -d "$resolvconfName"
    '';
    serviceConfig.Restart = "always";
  };
}
