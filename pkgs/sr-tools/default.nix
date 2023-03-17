{ fetchFromGitHub, imagemagick, libyaml, python3 }:

let
  basePython = python3;
  myPython = basePython.override {
    packageOverrides = self: super: {
      pyparsing = self.buildPythonPackage rec {
        pname = "pyparsing";
        version = "2.4.7";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:1hgc8qrbq1ymxbwfbjghv01fm3fbpjwpjwi0bcailxxzhf3yq0y2";
        };
        pythonImportsCheck = ["pyparsing"];
      };
      xlwt-future = self.buildPythonPackage rec {
        pname = "xlwt-future";
        version = "0.8.0";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:0zc8hhmvchywfnn893ipvmmm9mkphsj9kggrb57imzqw5p5byb55";
        };
        patches = [ ./xlwt-future-python36-compat.patch ];
        propagatedBuildInputs = with self; [ future ];
        doCheck = false;  # no tests
        pythonImportsCheck = ["xlwt"];
      };
    };
  };

in myPython.pkgs.buildPythonApplication rec {
  pname = "sr.tools";
  version = "6c129906ecedcbfcc667c522a44609b08d94b1af";
  src = fetchFromGitHub {
    owner = "srobo";
    repo = "tools";
    rev = version;
    hash = "sha256-tuBRNFdvNygeUXhALY/LZw8H3PRwTX61tFwfDqCttdw=";
  };
  nativeBuildInputs = with myPython.pkgs; [
    pygments
    sphinx
  ];
  propagatedBuildInputs = with myPython.pkgs; [
    beautifulsoup4
    basePython.pkgs.numpy  # For some reason the numpy package is non-reproducible at the moment. We *have* to use the binary cached version because building from source fails.
    pyparsing
    pyyaml
    requests
    setuptools  # not in setup.py, but needed at runtime
    six
    tabulate
    xlwt-future
  ];
  # Stop tests trying to touch $HOME.
  preConfigure = ''export SR_CACHE_DIR=$NIX_BUILD_TOP/sr-cache'';
  pythonImportsCheck = ["sr.tools"];
  passthru.python = myPython;
}
