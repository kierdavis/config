with import <nixpkgs> {};

import ./default.nix {
  inherit python35Packages udftools;
}
