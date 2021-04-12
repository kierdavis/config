{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [(self: super: {
    # Set cwd for boincmgr to the boinc data dir, so that it has no trouble finding the gui rpc password file.
    boinc = super.boinc.overrideDerivation (oldAttrs: {
      nativeBuildInputs = (if oldAttrs ? nativeBuildInputs then oldAttrs.nativeBuildInputs else []) ++ [ self.makeWrapper ];
      preFixup = ''
        ${if oldAttrs ? preFixup then oldAttrs.preFixup else ""}
        wrapProgram $out/bin/boincmgr --run 'cd ''${BOINC_DATA_DIR:-${config.services.boinc.dataDir}}'
      '';
      # Hide warnings when compiling.
      NIX_CFLAGS_COMPILE = (if oldAttrs ? NIX_CFLAGS_COMPILE then oldAttrs.NIX_CFLAGS_COMPILE else []) ++ [ "-w" ];
    });

    # Ensure backblaze B2 CLI is available in PATH.
    duplicity = super.duplicity.overrideDerivation (oldAttrs: {
      propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ self.backblaze-b2 ];
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
