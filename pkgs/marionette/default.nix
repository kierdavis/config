{ python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "marionette";
  version = "1";
  src = ./src;
  doCheck = false;
  propagatedBuildInputs = with python3Packages; [
    pyparsing
    requests_oauthlib
    typing-extensions
  ];
}
