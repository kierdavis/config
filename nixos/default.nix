let
  nixos = import <nixpkgs/nixos>;
in
  {
    coloris = nixos {
      configuration = machines/coloris.nix;
      system = "x86_64-linux";
    };

    ouroboros = nixos {
      configuration = machines/ouroboros.nix;
      system = "x86_64-linux";
    };

    nocturn = nixos {
      configuration = machines/nocturn.nix;
      system = "x86_64-linux";
    };
  }
