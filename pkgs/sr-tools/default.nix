{ fetchFromGitHub, imagemagick, libyaml, python37 }:

let
  basePython = python37;
  myPython = basePython.override {
    packageOverrides = self: super: {
      babel = self.buildPythonPackage rec {
        pname = "Babel";
        version = "2.6.0";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:08rxmbx2s4irp0w0gmn498vns5xy0fagm0fg33xa772jiks51flc";
        };
        propagatedBuildInputs = with self; [ pytz ];
        checkInputs = with self; [ freezegun pytest3CheckHook ];
        pythonImportsCheck = ["babel"];
      };
      docutils = self.buildPythonPackage rec {
        # Tests require Python < 3.8 because:
        #   ODT writer uses xml.etree to generate XML.
        #   Tests expect element attributes to be emitted in sorted order, but actually they are getting emitted in dict insertion order.
        #   This behaviour was changed in Python 3.8.
        #   Search "made predictable" at https://docs.python.org/3/library/xml.etree.elementtree.html
        pname = "docutils";
        version = "0.14";
        format = "wheel";
        src = self.fetchPypi {
          inherit pname version format;
          dist = "py3";
          python = "py3";
          hash = "sha256:19klwi9kymy1d1vib2cgxldz0fqp865a6f3sy9ppy1mbjayw9bh2";
        };
        pythonImportsCheck = ["docutils"];
      };
      execnet = super.execnet.override { pytestCheckHook = self.myPytestCheckHook; };
      filelock = super.filelock.override { pytestCheckHook = self.myPytestCheckHook; };
      future = self.buildPythonPackage rec {
        # test_pow requires Python < 3.8
        pname = "future";
        version = "0.18.2";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:0zakvfj87gy6mn1nba06sdha63rn4njm7bhh0wzyrxhcny8avgmi";
        };
        checkInputs = with self; [ myPytestCheckHook ];
        disabledTests = [
          # Requires network access:
          "test_moves_urllib_request_http"
          "test_urllib_request_http"
        ];
        pythonImportsCheck = ["future"];
      };
      jinja2 = self.buildPythonPackage rec {
        pname = "Jinja2";
        version = "3.0.3";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:1mvwr02s86zck5wsmd9wjxxb9iaqr17hdi5xza9vkwv8rmrv46v1";
        };
        propagatedBuildInputs = with self; [ babel markupsafe ];
        pythonImportsCheck = ["jinja2"];
      };
      hypothesis = super.hypothesis.override { pytestCheckHook = self.myPytestCheckHook; };
      pygments = self.buildPythonPackage rec {
        pname = "Pygments";
        version = "2.6.1";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:0i4gnd4q0mgkq0dp5wymn7ca8zjd8fgp63139svs6jf2c6h48wv4";
        };
        doCheck = false;  # circular dependencies
        pythonImportsCheck = ["pygments"];
      };
      pyparsing = self.buildPythonPackage rec {
        pname = "pyparsing";
        version = "2.4.7";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:1hgc8qrbq1ymxbwfbjghv01fm3fbpjwpjwi0bcailxxzhf3yq0y2";
        };
        pythonImportsCheck = ["pyparsing"];
      };
      # pytestCheckHook is special-cased and cannot be overridden.
      myPytestCheckHook = self.pytestCheckHook.override { inherit (self) pytest; };
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
        pythonImportsCheck = ["pytest"];
      };
      pytest3CheckHook = self.pytestCheckHook.override { pytest = self.pytest3; };
      pytest-asyncio = super.pytest-asyncio.override { pytestCheckHook = self.myPytestCheckHook; };
      pytest-forked = super.pytest-forked.override { pytestCheckHook = self.myPytestCheckHook; };
      pytest-mock = super.pytest-mock.override { pytestCheckHook = self.myPytestCheckHook; };
      pytest-xdist = super.pytest-xdist.override { pytestCheckHook = self.myPytestCheckHook; };
      pyyaml = self.buildPythonPackage rec {
        pname = "PyYAML";
        version = "5.4.1";
        src = self.fetchPypi {
          inherit pname version;
          hash = "sha256:0pm440pmpvgv5rbbnm8hk4qga5a292kvlm1bh3x2nwr8pb5p8xv0";
        };
        nativeBuildInputs = with self; [ cython ];
        buildInputs = [ libyaml ];
        pythonImportsCheck = ["yaml"];
      };
      requests = super.requests.override { pytestCheckHook = self.myPytestCheckHook; };
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
          babel
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
        checkInputs = with self; [ html5lib mock imagemagick pytest3CheckHook ];
        disabledTests = [
          # Requires network access:
          "test_build_linkcheck"
          "test_latex_images"
        ];
        pythonImportsCheck = ["sphinx"];
      };
      sr-tools = self.buildPythonApplication rec {
        pname = "sr.tools";
        version = "538bcd913fd0102c5427e27b65659f57b34d4e64";
        src = fetchFromGitHub {
          owner = "srobo";
          repo = "tools";
          rev = version;
          hash = "sha256:0az2isc61r9rgs697rzp3jn6brnv2a3kh2xjgc5x2dz1bgvzg1q3";
        };
        patches = [ ./sr-tools-fix-removed-commands.patch ];
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
        pythonImportsCheck = ["sr.tools"];
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
