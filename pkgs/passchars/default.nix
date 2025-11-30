{ python3Packages, pass }:

python3Packages.buildPythonApplication rec {
  name = "passchars-${version}";
  version = "0.1";

  src = ./src;
  pyproject = true;

  build-system = with python3Packages; [ setuptools ];
  propagatedBuildInputs = [ pass ];

  doCheck = false;
}
