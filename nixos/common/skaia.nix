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
      device = "10.143.215.140,10.143.255.123,10.143.254.226:${path}";
      fsType = "ceph";
      options = [
        "fs=fs"
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
    "/net/skaia/media" = f {
      path = "/volumes/csi/csi-vol-1ee62c83-b2fd-4bfd-aa6d-b76d743f17a0/70d38789-3f69-4a78-a44a-b14e68521b83";
    };
    "/net/skaia/torrent-downloads" = f {
      path = "/volumes/csi/csi-vol-180c05bf-2c66-4c9a-8b8f-015c1ec9fafd/59cb7613-1b2e-4167-8d22-7a1a31ed41c2";
    };
    "/net/skaia/projects" = f {
      path = "/volumes/csi/csi-vol-4d62c833-ed79-4e50-8a73-d1097a759dc3/e7bad2c3-2fc2-4439-972a-d939d24c7fbe";
    };
    "/net/skaia/documents" = f {
      path = "/volumes/csi/csi-vol-c8f70936-1f61-4532-a391-e4557af8d50e/2daff418-bd86-461d-8de0-ba84fa0abaa3";
    };
    "/net/skaia/transmission-state" = f {
      path = "/volumes/csi/csi-vol-ae56574b-380c-44e3-86e3-cf3656cb5351/2be25b47-ffda-40f0-b183-48b18b97ff53";
      options = ["ro"];
    };
  };
}
