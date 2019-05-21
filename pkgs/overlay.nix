self: super: {
  admesh = super.callPackage ./admesh { };
  boincgpuctl = super.callPackage ./boincgpuctl { };
  circleci = super.callPackage ./circleci { };
  ftb-launcher = super.callPackage ./ftb-launcher { };
  gds2svg = super.callPackage ./gds2svg { };
  hartmaster = super.callPackage ./hartmaster { };
  i3blocks-scripts = super.callPackage ./i3blocks-scripts { inherit (self.linuxPackages) nvidia_x11; };
  klayout = super.libsForQt5.callPackage ./klayout { };
  libkoki = super.callPackage ./libkoki { };
  lock = super.callPackage ./lock { };
  magic = super.callPackage ./magic { };
  modd = super.callPackage ./modd { };
  mountext = super.callPackage ./mountext { };
  mstream = super.callPackage ./mstream { nodejs = self."nodejs-8_x"; };
  netcheck = super.callPackage ./netcheck { };
  passchars = super.callPackage ./passchars { pythonPackages = self.python27Packages; };
  pcb-rnd = super.callPackage ./pcb-rnd { };
  publish = super.callPackage ./publish { };
  quartus = super.callPackage ./quartus { };
  redstore = super.callPackage ./redstore { };
  repetier-host = super.callPackage ./repetier-host { };
  riscv-gnu-toolchain = super.callPackage ./riscv-gnu-toolchain/default.nix { };
  screenshot = super.callPackage ./screenshot { inherit (self.gnome3) eog; };
  slic3r_1_3 = super.callPackage ./slic3r_1_3 { };
  umountext = super.callPackage ./umountext { };
}
