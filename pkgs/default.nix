import <nixpkgs> {
  overlays = [ (import ../patches/overlay.nix) (import ./overlay.nix) ];
}
