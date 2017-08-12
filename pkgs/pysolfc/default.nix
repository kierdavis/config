{ fetchurl, python2Packages }:

python2Packages.buildPythonApplication rec {
  name = "PySolFC-${version}";
  version = "2.0";

  src = fetchurl {
    url = "mirror://sourceforge/pysolfc/PySolFC-${version}.tar.bz2";
    sha256 = "0v0v8iflw55f5mghglkw80j8b7lv1hffjassfhqc4y84dmz8xjyv";
  };

  patches = [
    ./pysolfc-datadir.patch
  ];

  propagatedBuildInputs = [
    python2Packages.tkinter
  ];
}
