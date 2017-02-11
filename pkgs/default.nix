pkgs: pkgs // {
  archiveman = pkgs.callPackage ./archiveman { };
  ecs-rdp = pkgs.callPackage ./ecs-rdp { };
  ecs-rdp-tunnel = pkgs.callPackage ./ecs-rdp-tunnel { };
  ftb-launcher = pkgs.callPackage ./ftb-launcher { };
  i3blocks-scripts = pkgs.callPackage ./i3blocks-scripts { nvidia_x11 = pkgs.linuxPackages.nvidia_x11; };
  lock = pkgs.callPackage ./lock { };
  mountext = pkgs.callPackage ./mountext { };
  passchars = pkgs.callPackage ./passchars { pythonPackages = pkgs.python27Packages; };
  screenshot = pkgs.callPackage ./screenshot { eog = pkgs.gnome3.eog; };
  umountext = pkgs.callPackage ./umountext { };
}
