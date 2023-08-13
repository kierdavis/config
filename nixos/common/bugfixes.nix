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

    # https://discourse.nixos.org/t/while-mounting-ceph-filesystem-got-a-modprobe-not-found/23465
    ceph-client = self.stdenv.mkDerivation {
      name = "${super.ceph-client.name}-with-modprobe-fix";
      phases = "buildPhase";
      buildPhase = ''
        cp -rs ${super.ceph-client} $out
        chmod +w $out/bin
        rm -f $out/bin/mount.ceph
        cat > $out/bin/mount.ceph <<EOF
        #!${self.stdenv.shell}
        export PATH=${self.kmod}/bin:\$PATH
        exec ${super.ceph-client}/bin/mount.ceph "\$@"
        EOF
        chmod +x $out/bin/mount.ceph
      '';
    };

    # Install script wants to send error messages to /dev/tty,
    # but that device isn't available in the Nix build sandbox.
    cudatoolkit = super.cudatoolkit.overrideDerivation (oldAttrs: {
      unpackPhase = ''
        sed '1,400s:>\s*/dev/tty:>\&2:g' $src > install.run
        export src=$PWD/install.run
        ${oldAttrs.unpackPhase}
      '';
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
  virtualisation.podman.extraPackages = lib.optional (builtins.elem "zfs" config.boot.supportedFilesystems) pkgs.zfs;

  # The intention of restartIfChanged=false is to avoid killing user sessions when restarting the service.
  # But, xrdp-sesman already handles this safely - upon receiving SIGINT it waits for all sessions to be terminated before exiting.
  systemd.services.xrdp-sesman.restartIfChanged = lib.mkForce true;

  # If no X server is enabled, programs.gnupg.agent.pinentryFlavor defaults to null.
  # But this means that gpg-agent looks for pinentry within the gpg distribution (but we've compiled it out in favour of third-party pinentry).
  programs.gnupg.agent = lib.optionalAttrs (!config.services.xserver.enable) { pinentryFlavor = "curses"; };

  # Default value of "pause:latest" doesn't exist on Docker Hub???
  virtualisation.containerd.settings.plugins."io.containerd.grpc.v1.cri".sandbox_image = "kubernetes/pause";

  system.fsPackages = lib.optional (builtins.elem "ceph" config.boot.supportedFilesystems) pkgs.ceph-client;
}
