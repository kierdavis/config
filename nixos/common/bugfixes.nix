{ config, lib, pkgs, ... }:

let
  pkgs1 = import (pkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "eb7e1ef185f6c990cda5f71fdc4fb02e76ab06d5";
    hash = "sha256:1ibz204c41g7baqga2iaj11yz9l75cfdylkiqjnk5igm81ivivxg";
  }) {};
in

{
  nixpkgs.overlays = [(self: super: {
    # Doesn't work in current release.
    inherit (pkgs1) freecad;

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

    # --podman isn't available in any release yet.
    x11docker = super.x11docker.overrideDerivation (oldAttrs: {
      version = "6.6.2-unstable";
      src = self.fetchFromGitHub {
        owner = "mviereck";
        repo = "x11docker";
        rev = "0d5537c31d4e5202cd6d57565fc234541659fdc2";
        sha256 = "0fjh5c7fiwmfav2x7lxs5gpql97ad0annh93w00qdqjpik0yvwif";
      };
    });
  })];

  # If podman detects its storage is backed by zfs, it will try to use the
  # zfs admin commands to manage container volumes. These aren't in
  # podman's PATH by default.
  virtualisation.podman.extraPackages = lib.optional (builtins.elem "zfs" config.boot.supportedFilesystems) pkgs.zfs;
}
