self: super: {
  chromium = self.callPackage ./chromium {};
  dmenu = super.dmenu.overrideDerivation (oldAttrs: {
    patches = (if oldAttrs ? patches && oldAttrs.patches != null then oldAttrs.patches else []) ++ [ ./dmenu-focus.patch ];
  });
  duplicity = super.duplicity.overrideDerivation (oldAttrs: {
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ self.backblaze-b2 ];
  });
}
