self: super: {
  dmenu = super.dmenu.overrideDerivation (oldAttrs: {
    patches = (if oldAttrs ? patches && oldAttrs.patches != null then oldAttrs.patches else []) ++ [ ./dmenu-focus.patch ];
  });
}
