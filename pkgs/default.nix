pkgs: pkgs // {
  archiveman = pkgs.callPackage ./archiveman { };
  boincgpuctl = pkgs.callPackage ./boincgpuctl { };
  freesweep = pkgs.callPackage_i686 ./freesweep { };
  ftb-launcher = pkgs.callPackage ./ftb-launcher { };
  gds2svg = pkgs.callPackage ./gds2svg { };
  home-manager = pkgs.callPackage ./home-manager { };
  i3blocks-scripts = pkgs.callPackage ./i3blocks-scripts { nvidia_x11 = pkgs.linuxPackages.nvidia_x11; };
  lock = pkgs.callPackage ./lock { };
  mountext = pkgs.callPackage ./mountext { };
  passchars = pkgs.callPackage ./passchars { pythonPackages = pkgs.python27Packages; };
  pcb-rnd = pkgs.callPackage ./pcb-rnd { };
  pysolfc = pkgs.callPackage ./pysolfc { };
  publish = pkgs.callPackage ./publish { };
  redstore = pkgs.callPackage ./redstore { };
  screenshot = pkgs.callPackage ./screenshot { eog = pkgs.gnome3.eog; };
  soton-mount = pkgs.callPackage ./soton-mount { };
  soton-rdp = pkgs.callPackage ./soton-rdp { };
  soton-umount = pkgs.callPackage ./soton-umount { };
  umountext = pkgs.callPackage ./umountext { };
}
