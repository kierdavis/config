let
  allFeatures = rec {
    fp_fs = {
      name = "fp_fs";
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
    };
  };

  defaultFeatures = fs: {
    inherit (fs) fp_fs io_lihata io_pcb hid_gtk2_gdk;
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

  src = import ./source.nix { inherit stdenv fetchsvn; };

in stdenv.mkDerivation rec {
  inherit src;
  inherit (src) rev;

  name = "pcb-rnd-${version}";
  version = "svn-r${rev}";

  configureFlags = [ "--all=disable" ] ++ enabledFeatureConfigureFlags;

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = enabledFeatureBuildInputs;
}
