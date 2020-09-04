{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    modd
    (pkgs.python3.withPackages (pyPkgs: with pyPkgs; [
      mypy
      pyparsing
      pytest
      requests_oauthlib
      testfixtures
      typing_extensions
    ]))
  ];
  PYTHONPATH = ["."];
}
