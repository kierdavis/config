let
  allFeatures = rec {
    lib_hid_common = {
      name = "lib_hid_common";
    };
    lib_gtk_hid = {
      # For some reason this feature is broken in isolation.
      # When used as a dependency of hid_gtk2_gdk, however,
      # there are no problems.
      name = "lib_gtk_hid";
      buildInputs = { gtk2, ... }: [ gtk2.dev ];
      deps = [ lib_hid_common ];
    };
    io_lihata = {
      name = "io_lihata";
    };
    io_pcb = {
      name = "io_pcb";
    };
    hid_gtk2_gdk = {
      name = "hid_gtk2_gdk";
      buildInputs = { gtk2, ... }: [ gtk2.dev ];
      deps = [ lib_gtk_hid ];
    };
  };

  defaultFeatures = fs: {
    inherit (fs) io_lihata io_pcb hid_gtk2_gdk;
  };
in

args@{
  fetchsvn,
  gtk2,
  #gtk3,
  #gtkglext,
  #lesstif,
  #libXt,
  pkgconfig,
  stdenv,

  features ? defaultFeatures
}:

with stdenv.lib;

let
  # 'features' is the parameter provided to the derivation,
  # a function that takes the set of all features and returns
  # a subset.
  enabledFeatures = features allFeatures;

  featureConfigureFlags = f: concatMap featureConfigureFlags (if f ? deps then f.deps else [])
    ++ [ "--buildin-${f.name}" ];

  enabledFeatureConfigureFlags = concatMap featureConfigureFlags (attrValues enabledFeatures);

  featureBuildInputs = f: concatMap featureBuildInputs (if f ? deps then f.deps else [])
    ++ (if f ? buildInputs then f.buildInputs args else []);

  enabledFeatureBuildInputs = concatMap featureBuildInputs (attrValues enabledFeatures);

in stdenv.mkDerivation rec {
  name = "pcb-rnd-${version}";
  version = "svn-r${svnRevision}";
  svnRevision = "12693";

  src = fetchsvn {
    url = "svn://repo.hu/pcb-rnd/trunk";
    rev = svnRevision;
    sha256 = "0cmy048s807axy89y202b1cwbl1434cdjls7mjnazjflb1wg3zfb";
  };

  patches = [
    ./fix-sphash-printf-warnings.patch
  ];

  configureFlags = [ "--all=disable" ] ++ enabledFeatureConfigureFlags;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = enabledFeatureBuildInputs;
}
