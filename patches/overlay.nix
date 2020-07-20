self: super: {
  boinc = super.boinc.overrideDerivation (oldAttrs: {
    nativeBuildInputs = (if oldAttrs ? nativeBuildInputs then oldAttrs.nativeBuildInputs else []) ++ [ self.makeWrapper ];
    preFixup = ''
      ${if oldAttrs ? preFixup then oldAttrs.preFixup else ""}
      wrapProgram $out/bin/boincmgr --run 'cd ''${BOINC_DATA_DIR:-/var/lib/boinc}'
    '';
  });
  duplicity = super.duplicity.overrideDerivation (oldAttrs: {
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ self.backblaze-b2 ];
  });
}
