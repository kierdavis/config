{ python35Packages, udftools }:

python35Packages.buildPythonApplication rec {
  name = "archiveman-${version}";
  version = "0.1";

  src = ./src;

  propagatedBuildInputs = with python35Packages; [
    docopt
    sqlalchemy
    udftools
  ];

  doCheck = false;
}
