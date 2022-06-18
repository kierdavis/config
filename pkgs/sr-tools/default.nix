{ fetchFromGitHub, imagemagick, python37 }:

let
  basePython = python37;
  myPython = basePython.override {
    packageOverrides = self: super: {
      Babel = self.buildPythonPackage rec {
        pname = "Babel";
        version = "2.6.0";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:08rxmbx2s4irp0w0gmn498vns5xy0fagm0fg33xa772jiks51flc";
        };
        propagatedBuildInputs = with self; [ pytz ];
        checkInputs = with self; [ freezegun pytest3CheckHook ];
      };
      docutils = self.buildPythonPackage rec {
        # Tests require Python < 3.8 because:
        #   ODT writer uses xml.etree to generate XML.
        #   Tests expect element attributes to be emitted in sorted order, but actually they are getting emitted in dict insertion order.
        #   This behaviour was changed in Python 3.8.
        #   Search "made predictable" at https://docs.python.org/3/library/xml.etree.elementtree.html
        # Requires setuptools < 58.0.0 because we need build_py_2to3.
        pname = "docutils";
        version = "0.14";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:0x22fs3pdmr42kvz6c654756wja305qv6cx1zbhwlagvxgr4xrji";
        };
        patches = [ ./docutils-reveal-import-errors.patch ];
        checkPhase = ''
          cd test3
          ./alltests.py
        '';
      };
      future = self.buildPythonPackage rec {
        # test_pow requires Python < 3.8
        pname = "future";
        version = "0.18.2";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:0zakvfj87gy6mn1nba06sdha63rn4njm7bhh0wzyrxhcny8avgmi";
        };
        checkInputs = with self; [ pytestCheckHook ];
        disabledTests = [
          # Requires network access:
          "test_moves_urllib_request_http"
          "test_urllib_request_http"
        ];
      };
      pygments = self.buildPythonPackage rec {
        pname = "Pygments";
        version = "2.6.1";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:0i4gnd4q0mgkq0dp5wymn7ca8zjd8fgp63139svs6jf2c6h48wv4";
        };
        checkInputs = with self; [ pytestCheckHook ];
      };
      # Needed, otherwise pytest gets derived using our custom versions of docutils etc.
      # This is bad because pytestCheckHook uses a fixed, non-overridable version of pytest.
      # So if you make any changes to python.pkgs.pytest, you'll end up with multiple conflicting versions of pytest in the environment.
      pytest = basePython.pkgs.pytest;
      # However, we're free to define a custom pytest hook under a different name.
      pytest3 = self.buildPythonPackage rec {
        pname = "pytest";
        version = "3.10.1";
        # tar.gz tries to do some hot-downloading of a wheel.
        format = "wheel";
        src = self.fetchPypi {
          inherit pname version format;
          python = "py2.py3";
          hash = "sha256:1v2812ixqzs4r5akzzb0c66v2cnmlfz3hf2q9jfn1lg1rzqks69z";
        };
        propagatedBuildInputs = with self; [
          atomicwrites
          attrs
          more-itertools
          pluggy
          py
          six
        ];
      };
      pytest3CheckHook = self.pytestCheckHook.override { pytest = self.pytest3; };
      sphinx = self.buildPythonPackage rec {
        # test_correct_year requires Babel < 2.7.0 (https://github.com/python-babel/babel/commit/ea5bc4988bf7c3be84d296eb874aa11ed86c907d)
        # test_intl requires requires docutils < 0.15 (https://github.com/sphinx-doc/sphinx/issues/6620)
        # test_literal_include_linenos requires pygments < 2.7.0 (https://github.com/pygments/pygments/commit/728fd19eb changes the emitted HTML)
        pname = "Sphinx";
        version = "1.8.5";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:c7658aab75c920288a8cf6f09f244c6cfdae30d82d803ac1634d9f223a80ca08";
        };
        propagatedBuildInputs = with self; [
          alabaster
          Babel
          docutils
          imagesize
          jinja2
          packaging
          pygments
          requests
          setuptools
          six
          snowballstemmer
          sphinxcontrib-websupport
        ];
        checkInputs = with self; [ html5lib mock imagemagick pytestCheckHook ];
        disabledTests = [
          # Requires network access:
          "test_build_linkcheck"
          "test_latex_images"
        ];
      };
      sr-tools = self.buildPythonApplication rec {
        pname = "sr.tools";
        version = "8aac0f6b6eaedb78195b74739e5613e62bad7c75";
        src = fetchFromGitHub {
          owner = "srobo";
          repo = "tools";
          rev = version;
          hash = "sha256:1a1sphafr1gas9x591jx2xcapw7y7dikn61ak1zqcnfdr6b8m8b4";
        };
        nativeBuildInputs = with self; [
          docutils
          pygments
          sphinx
        ];
        propagatedBuildInputs = with self; [
          beautifulsoup4
          numpy
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

in myPython.pkgs.sr-tools
