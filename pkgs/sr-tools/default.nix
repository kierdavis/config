{ glibcLocales, libyaml, python3Packages }:

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

  pyyaml3 = python3Packages.buildPythonPackage rec {
    pname = "PyYAML";
    version = "3.13";
    src = fetchPypi {
      inherit pname version;
      sha256 = "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf";
    };
    propagatedBuildInputs = [ libyaml ];
    doCheck = false;  # failing :(
  };

  sphinx1 = python3Packages.buildPythonPackage rec {
    pname = "sphinx";
    version = "1.8.5";
    src = fetchPypi {
      pname = "Sphinx";
      inherit version;
      sha256 = "c7658aab75c920288a8cf6f09f244c6cfdae30d82d803ac1634d9f223a80ca08";
    };
    LC_ALL = "en_US.UTF-8";

    buildInputs = with python3Packages; [ simplejson mock glibcLocales html5lib ];
    propagatedBuildInputs = with python3Packages; [
      alabaster
      Babel
      docutils
      imagesize
      jinja2
      pygments
      requests
      setuptools
      six
      snowballstemmer
      sphinxcontrib-websupport
      sqlalchemy
      whoosh
    ];

    # Disable two tests that require network access.
    #checkPhase = "pytest -k 'not test_defaults and not test_anchors_ignored'";
    #checkInputs = with python3Packages; [ pytest ];
    doCheck = false;

    # https://github.com/NixOS/nixpkgs/issues/22501
    # Do not run `python sphinx-build arguments` but `sphinx-build arguments`.
    postPatch = ''
      substituteInPlace sphinx/make_mode.py --replace "sys.executable, " ""
    '';
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
      sphinx1
    ];
    propagatedBuildInputs = with python3Packages; [
      beautifulsoup4
      numpy
      pygit2
      pyparsing
      pyyaml3
      requests
      setuptools  # needs pkg_resources at runtime
      six
      sympy0
      tabulate
      xlwt-future
    ];
    # Stop tests trying to touch $HOME.
    preConfigure = ''export SR_CACHE_DIR=$NIX_BUILD_TOP/sr-cache'';
  };

in sr-tools
