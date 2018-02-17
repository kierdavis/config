self: super: {
  archiveman = super.callPackage ./archiveman { };
  boincgpuctl = super.callPackage ./boincgpuctl { };
  boincmgr = super.callPackage ./boincmgr { inherit (self.xorg) xauth; };
  circleci = super.callPackage ./circleci { };
  freesweep = super.callPackage_i686 ./freesweep { };
  ftb-launcher = super.callPackage ./ftb-launcher { };
  gds2svg = super.callPackage ./gds2svg { };
  home-manager = super.callPackage ./home-manager { };
  i3blocks-scripts = super.callPackage ./i3blocks-scripts { inherit (self.linuxPackages) nvidia_x11; };
  lock = super.callPackage ./lock { };
  mountext = super.callPackage ./mountext { };
  passchars = super.callPackage ./passchars { pythonPackages = self.python27Packages; };
  pcb-rnd = super.callPackage ./pcb-rnd { };
  pysolfc = super.callPackage ./pysolfc { };
  publish = super.callPackage ./publish { };
  redstore = super.callPackage ./redstore { };
  screenshot = super.callPackage ./screenshot { inherit (self.gnome3) eog; };
  soton-mount = super.callPackage ./soton-mount { };
  soton-rdp = super.callPackage ./soton-rdp { };
  soton-umount = super.callPackage ./soton-umount { };
  umountext = super.callPackage ./umountext { };
}
