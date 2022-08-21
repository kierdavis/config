{ haskell
, lib
}:

let hsPkgs = haskell.packages.ghc8107; in

hsPkgs.mkDerivation {
  pname = "sv2v";
  version = "0.0.10";
  sha256 = "00h7f8dmi17r4bcyzm25d6avvxdi8fqfxmvh7ssg9kqcbbix9xkd";
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = with hsPkgs; [
    array cmdargs directory filepath githash hashable
    mtl vector
  ];
  executableToolDepends = with hsPkgs; [ alex happy ];
  description = "SystemVerilog to Verilog conversion";
  license = lib.licenses.bsd3;
  hydraPlatforms = lib.platforms.none;
}
