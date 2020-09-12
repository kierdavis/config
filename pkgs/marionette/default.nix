{ python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "marionette";
  version = "1";
  src = ./src;
  doCheck = false;
  propagatedBuildInputs = (import ./common.nix).requires python3Packages;
}
