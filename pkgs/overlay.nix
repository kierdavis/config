self: super: {
  admesh = super.callPackage ./admesh { };
  boincgpuctl = super.callPackage ./boincgpuctl { };
  circleci = super.callPackage ./circleci { };
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
  openttd_1_10_2 = super.callPackage ./openttd-1.10.2 { };
  passchars = super.callPackage ./passchars { pythonPackages = self.python27Packages; };
  pcb-rnd = super.callPackage ./pcb-rnd { };
  pout = super.callPackage ./pout { };
  quartus = super.callPackage ./quartus { };
  redstore = super.callPackage ./redstore { };
  repetier-host = super.callPackage ./repetier-host { };
  riscv-gnu-toolchain = super.callPackage ./riscv-gnu-toolchain/default.nix { };
  rustc-commit-db = super.callPackage ./rustc-commit-db { };
  screenshot = super.callPackage ./screenshot { inherit (self.gnome3) eog; };
  sr-tools = super.callPackage ./sr-tools { };
  umountext = super.callPackage ./umountext { };
}
