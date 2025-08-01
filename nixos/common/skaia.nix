{ config, pkgs, lib, ... }:

{
  systemd.targets.skaia = {
    wantedBy = ["multi-user.target"];
    before = ["multi-user.target"];
  };

  services.tailscale = {
    enable = true;
    interfaceName = "skaia";
    authKeyFile = "/etc/skaia-headscale-auth-key";
    extraUpFlags = [
      "--accept-dns=false"
      "--accept-routes=true"
      # XXX: this option appears to have no effect? `tailscale debug prefs` reports AdvertiseTags is still null?
      ("--advertise-tags=" + lib.concatMapStringsSep "," (t: "tag:" + t) config.services.tailscale.advertiseTags)
      "--login-server=https://headscale.skaia.cloud/"
    ];
  };
  systemd.services.tailscaled = {
    wantedBy = lib.mkForce ["skaia.target"];
    before = ["skaia.target"];
  };
  systemd.services.tailscaled-autoconnect = {
    wantedBy = lib.mkForce ["skaia.target"];
    before = ["skaia.target"];
    serviceConfig.TimeoutStartSec = 20;
  };

  systemd.services.skaia-dns = {
    wantedBy = ["skaia.target"];
    wants = ["tailscaled.service" "tailscaled-autoconnect.service"];
    before = ["skaia.target"];
    after = ["tailscaled.service" "tailscaled-autoconnect.service"];
    path = [pkgs.bind.host pkgs.openresolv];
    environment = {
      server = "10.143.128.10";
      testHost = "kube-dns.kube-system.svc.kube.skaia.cloud";
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

  fileSystems = let
    f = { path, options ? [] }: {
      device = "10.143.215.140,10.143.238.176,10.143.231.128:${path}";
      fsType = "ceph";
      options = [
        "fs=cephfs"
        "name=${config.networking.hostName}"
        "secretfile=/etc/ceph-client-secret"
        "x-systemd.wanted-by=skaia.target"
        "x-systemd.before=skaia.target"
        "x-systemd.requires=tailscaled.service"             # implies After=tailscaled.service
        "x-systemd.requires=tailscaled-autoconnect.service" # implies After=tailscaled-autoconnect.service
        "x-systemd.mount-timeout=10s"
      ] ++ options;
    };
  in {
    "/net/skaia/torrent-downloads" = f {
      path = "/volumes/csi/csi-vol-d8583d63-3083-4a4f-8707-0420c65c4893/5f9b0a16-dc06-47bc-bb77-8bb34915bcd6";
    };
    "/net/skaia/media" = f {
      path = "/volumes/csi/csi-vol-c8f02543-bf22-4fb2-b6b3-f400d4836e1b/1e0f38a6-d9d1-4425-9aa4-bb6ea87da949";
    };
    "/net/skaia/music" = f {
      path = "/volumes/csi/csi-vol-54a4ce26-5a39-4229-bd0d-47270f7aee0a/abe4fb2b-c2ed-4afc-81d1-9818b808cf4a";
    };
    "/net/skaia/photography" = f {
      path = "/volumes/csi/csi-vol-24c8ce5d-a4be-4102-8e77-bffe92814b48/8b59a182-01dd-4b9d-b84f-1c3bab9df3f3";
    };
    "/net/skaia/projects" = f {
      path = "/volumes/csi/csi-vol-1d50ce19-2828-4237-a36e-57389f09cf4a/ed285016-c098-4b9f-a261-472e81fc2979";
    };
    "/net/skaia/documents" = f {
      path = "/volumes/csi/csi-vol-afba2d2b-2a40-457a-9aa7-2208c7360caa/012b5be3-27da-49aa-84c6-ddd1573da931";
    };
    "/net/skaia/transmission-state" = f {
      path = "/volumes/csi/csi-vol-7a599792-b24e-423b-a3f5-57edaeddcc0b/55bc5ef0-2240-4f68-8d95-aeb2b3ab75d0";
      options = ["ro"];
    };
    "/net/skaia/tfstate" = f {
      path = "/volumes/csi/csi-vol-3a69a873-2b0b-43db-aa3d-cc1d98a43431/539810b6-2e17-408b-98f8-d44bbffba2bf";
    };
  };
}
