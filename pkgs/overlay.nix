self: super: {
  admesh = super.callPackage ./admesh { };
  balsa = super.callPackage ./balsa { };
  boincgpuctl = super.callPackage ./boincgpuctl { };
  circleci = super.callPackage ./circleci { };
  dalle-playground = super.callPackage ./dalle-playground { };
  espresso = super.callPackage ./espresso { };
  fina = super.callPackage ./fina { };
  ftb-launcher = super.callPackage ./ftb-launcher { };
  gds2svg = super.callPackage ./gds2svg { };
  hartmaster = super.callPackage ./hartmaster { };
  i3blocks-scripts = super.callPackage ./i3blocks-scripts { inherit (self.linuxPackages) nvidia_x11; };
  igdm = super.callPackage ./igdm { };
  klayout = super.libsForQt5.callPackage ./klayout { };
  libkoki = super.callPackage ./libkoki { };
  lock = super.callPackage ./lock { };
  magic = super.callPackage ./magic { };
  marionette = super.callPackage ./marionette { };
  mountext = super.callPackage ./mountext { };
  mstream = super.callPackage ./mstream { nodejs = self."nodejs-8_x"; };
  ndpi4 = super.callPackage ./ndpi4 { };
  netbootxyz = super.callPackage ./netbootxyz { };
  ntopng5 = super.callPackage ./ntopng5 { inherit (self.nodePackages) uglify-js; };
  openttd_1_10_2 = super.callPackage ./openttd-1.10.2 { };
  passchars = super.callPackage ./passchars { };
  pcb-rnd = super.callPackage ./pcb-rnd { };
  petrify = super.callPackage ./petrify { };
  pout = super.callPackage ./pout { };
  quartus = super.callPackage ./quartus { };
  redstore = super.callPackage ./redstore { };
  repetier-host = super.callPackage ./repetier-host { };
  riscv-gnu-toolchain = super.callPackage ./riscv-gnu-toolchain/default.nix { };
  screenshot = super.callPackage ./screenshot { };
  sr-tools = super.callPackage ./sr-tools { };
  sv2v = super.callPackage ./sv2v { };
  xrdp = super.callPackage ./xrdp-glamor { };
  umountext = super.callPackage ./umountext { };

  kdenlive = super.kdenlive.overrideDerivation (oldAttrs: {
    patches = (oldAttrs.patches or []) ++ [ ./kdenlive-avoid-crash.patch ];
  });
}
