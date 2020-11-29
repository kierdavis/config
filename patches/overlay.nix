self: super:

{
  boinc = super.boinc.overrideDerivation (oldAttrs: {
    nativeBuildInputs = (if oldAttrs ? nativeBuildInputs then oldAttrs.nativeBuildInputs else []) ++ [ self.makeWrapper ];
    preFixup = ''
      ${if oldAttrs ? preFixup then oldAttrs.preFixup else ""}
      wrapProgram $out/bin/boincmgr --run 'cd ''${BOINC_DATA_DIR:-/var/lib/boinc}'
    '';
    NIX_CFLAGS_COMPILE = (if oldAttrs ? NIX_CFLAGS_COMPILE then oldAttrs.NIX_CFLAGS_COMPILE else []) ++ [ "-w" ];
  });

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

  podman-unwrapped = super.podman-unwrapped.overrideDerivation (oldAttrs: {
    patches = [
      # fix a bug triggered by x11docker
      (self.fetchpatch {
        url = "https://github.com/containers/podman/commit/8d12d8104f9599dc10435f8c5ce88d1bde0ca1bc.patch";
        sha256 = "11xdigfw0wrmkhiablpj2gxn26gacd2cyfx6mav7pfqwhfmvqsnb";
      })
    ];
  });
}
