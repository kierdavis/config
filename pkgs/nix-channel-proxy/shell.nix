with import <nixpkgs> {};

mkShell {
  buildInputs = [
    gnumake
    (python3.withPackages (py: with py; [
      black
      flake8
      isort
      mypy
    ]))
  ];
}
