{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    modd
    (pkgs.python3.withPackages (pyPkgs: with pyPkgs; ((import ./common.nix).requires pyPkgs) ++ [
      mypy
      pytest
      testfixtures
    ]))
  ];
  PYTHONPATH = ["."];
}
