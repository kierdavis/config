{ pythonPackages, pass }:

pythonPackages.buildPythonApplication rec {
  name = "passchars-${version}";
  version = "0.1";

  src = ./src;

  propagatedBuildInputs = [ pass ];

  doCheck = false;
}
