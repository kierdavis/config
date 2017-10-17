pkgs: pkgs // {
  archiveman = pkgs.callPackage ./archiveman { };
  boincgpuctl = pkgs.callPackage ./boincgpuctl { };
  ecs-mount = pkgs.callPackage ./ecs-mount { };
  ecs-rdp-roo = pkgs.callPackage ./ecs-rdp-roo { };
  ecs-umount = pkgs.callPackage ./ecs-umount { };
  ftb-launcher = pkgs.callPackage ./ftb-launcher { };
  gds2svg = pkgs.callPackage ./gds2svg { };
  home-manager = pkgs.callPackage ./home-manager { };
  i3blocks-scripts = pkgs.callPackage ./i3blocks-scripts { nvidia_x11 = pkgs.linuxPackages.nvidia_x11; };
  lock = pkgs.callPackage ./lock { };
  mountext = pkgs.callPackage ./mountext { };
  passchars = pkgs.callPackage ./passchars { pythonPackages = pkgs.python27Packages; };
  pysolfc = pkgs.callPackage ./pysolfc { };
  publish = pkgs.callPackage ./publish { };
  redstore = pkgs.callPackage ./redstore { };
  screenshot = pkgs.callPackage ./screenshot { eog = pkgs.gnome3.eog; };
  umountext = pkgs.callPackage ./umountext { };
}
