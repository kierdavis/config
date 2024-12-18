{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [(self: super: {
  })];

  # The intention of restartIfChanged=false is to avoid killing user sessions when restarting the service.
  # But, xrdp-sesman already handles this safely - upon receiving SIGINT it waits for all sessions to be terminated before exiting.
  systemd.services.xrdp-sesman.restartIfChanged = lib.mkForce true;

  # Default value of "pause:latest" doesn't exist on Docker Hub???
  virtualisation.containerd.settings.plugins."io.containerd.grpc.v1.cri".sandbox_image = "kubernetes/pause";

  system.fsPackages = lib.optional (config.boot.supportedFilesystems.ceph or false) pkgs.ceph-client;

  # https://github.com/NixOS/nixpkgs/issues/247434
  services.xserver.displayManager.setupCommands = lib.optionalString
    config.services.autorandr.enable
    "${pkgs.autorandr}/bin/autorandr --change || true";
}
