self: super: {
  dmenu = super.dmenu.overrideDerivation (oldAttrs: {
    patches = (if oldAttrs.patches != null then oldAttrs.patches else []) ++ [ ./dmenu-focus.patch ];
  });
}
