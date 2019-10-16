self: super: {
  duplicity = super.duplicity.overrideDerivation (oldAttrs: {
    propagatedBuildInputs = oldAttrs.propagatedBuildInputs ++ [ self.backblaze-b2 ];
  });
}
