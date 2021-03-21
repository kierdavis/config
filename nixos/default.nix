let
  nixpkgs = import <nixpkgs> {};
  nixos = import <nixpkgs/nixos>;
in
  rec {
    coloris = nixos {
      configuration = machines/coloris.nix;
      system = "x86_64-linux";
    };

    # Hint:
    # nix-build -A coloris-win.system.build.tarball
    # wsl --import DISTRO_NAME FS_IMAGE_DIR result/tarball/*.tar.gz --version 2
    coloris-win = nixos {
      configuration = machines/coloris-win.nix;
      system = "x86_64-linux";
    };

    saelli = nixos {
      configuration = machines/saelli.nix;
      system = "x86_64-linux";
    };
  }
