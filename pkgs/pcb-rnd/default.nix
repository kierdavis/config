let
  allFeatures = {
    fp_fs = {};
    io_lihata = {};
    io_pcb = {};
    hid_gtk2_gdk = {
      buildInputs = { gtk2, ... }: [ gtk2.dev ];
    };
    #hid_gtk2_gl = {
    #  buildInputs = { gtk2, gtkglext, ... }: [ gtk2.dev gtkglext ];
    #};
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
  lib,
  #libXt,
  pkgconfig,
  stdenv,

  features ? defaultFeatures
}:

with lib;

let
  # 'features' is the parameter provided to the derivation,
  # a function that takes the set of all features and returns
  # a subset.
  allFeaturesWithNames = mapAttrs (name: feature: feature // { inherit name; }) allFeatures;
  enabledFeatures = features allFeaturesWithNames;
  enabledFeatureConfigureFlags = concatMap
    (f: [ "--buildin-${f.name}" ])
    (attrValues enabledFeatures);
  enabledFeatureBuildInputs = concatMap
    (f: if f ? buildInputs then f.buildInputs args else [])
    (attrValues enabledFeatures);

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
