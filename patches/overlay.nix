self: super: {
  chromium = self.callPackage ./chromium {};
  duplicity = super.duplicity.overrideDerivation (oldAttrs: {
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ self.backblaze-b2 ];
  });
}
