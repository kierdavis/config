{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [(self: super: {
    # Set cwd for boincmgr to the boinc data dir, so that it has no trouble finding the gui rpc password file.
    boinc = super.boinc.overrideDerivation (oldAttrs: {
      nativeBuildInputs = (if oldAttrs ? nativeBuildInputs then oldAttrs.nativeBuildInputs else []) ++ [ self.makeWrapper ];
      preFixup = ''
        ${if oldAttrs ? preFixup then oldAttrs.preFixup else ""}
        if [[ -e $out/bin/boincmgr ]]; then
          wrapProgram $out/bin/boincmgr --run 'cd ''${BOINC_DATA_DIR:-${config.services.boinc.dataDir}}'
        fi
      '';
      # Hide warnings when compiling.
      NIX_CFLAGS_COMPILE = (if oldAttrs ? NIX_CFLAGS_COMPILE then oldAttrs.NIX_CFLAGS_COMPILE else []) ++ [ "-w" ];
    });

    # Fix hardcoded filenames, and expectation of xinit being on PATH.
    tigervnc = super.tigervnc.overrideDerivation (oldAttrs: {
      preFixup = ''
        substituteInPlace $out/bin/.vncserver-wrapped \
          --replace /etc/X11/xinit/Xsession '$ENV{XSESSION}' \
          --replace /usr/share/xsessions '$ENV{XSESSIONS_DIR}' \
          --replace '$vncUserDir/config' '$ENV{CONFIG}'
        wrapProgram $out/bin/.vncserver-wrapped \
          --prefix PATH : ${lib.makeBinPath [pkgs.xorg.xinit]} \
          --set-default XSESSION ${config.services.xserver.displayManager.sessionData.wrapper} \
          --set-default XSESSIONS_DIR /usr/share/xsessions \
          --set-default CONFIG '$HOME/.vnc/config'
        ${oldAttrs.preFixup or ""}
      '';
    });
  })];

  # If podman detects its storage is backed by zfs, it will try to use the
  # zfs admin commands to manage container volumes. These aren't in
  # podman's PATH by default.
  virtualisation.podman.extraPackages = lib.optional (config.boot.supportedFilesystems.zfs or false) pkgs.zfs;

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
