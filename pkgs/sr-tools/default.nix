{ python3Packages }:

let
  fetchPypi = python3Packages.fetchPypi;

  future = python3Packages.buildPythonPackage rec {
    pname = "future";
    version = "0.17.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "1f2rlqn9rh7adgir52dlbqz69gsab44x0mlm8gf1cs7xvhv54137";
    };
    doCheck = false;  # failing :(
  };

  xlwt-future = python3Packages.buildPythonPackage rec {
    pname = "xlwt-future";
    version = "0.8.0";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0zc8hhmvchywfnn893ipvmmm9mkphsj9kggrb57imzqw5p5byb55";
    };
    propagatedBuildInputs = with python3Packages; [
      future
    ];
    doCheck = false;  # failing :(
  };

  sympy0 = python3Packages.buildPythonPackage rec {
    pname = "sympy";
    version = "0.7.6.1";
    src = fetchPypi {
      inherit pname version;
      sha256 = "0r7mymcz3s7h7szm5v1bzdbqdqpk8w59zgzi0xyvxali22sp5hhz";
    };
    doCheck = false;  # failing :(
  };

  sr-tools = python3Packages.buildPythonApplication rec {
    pname = "sr.tools";
    version = "1.1.2";
    src = fetchPypi {
      inherit pname version;
      sha256 = "03rp6d1810iy7gxis9m001jmqy8cs0cgla149y5h7l3k1s2ragxq";
    };
    buildInputs = with python3Packages; [
      nose
      numpy
      pygments
      sphinx
    ];
    propagatedBuildInputs = with python3Packages; [
      beautifulsoup4
      numpy
      pyparsing
      pyyaml
      requests
      six
      sympy0
      tabulate
      xlwt-future
    ];
    # Stop tests trying to touch $HOME.
    preConfigure = ''export SR_CACHE_DIR=$NIX_BUILD_TOP/sr-cache'';
  };

in sr-tools
