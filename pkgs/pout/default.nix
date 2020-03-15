{ stdenv, intltool, wrapGAppsHook, libcanberra-gtk3, pkgconfig, gtk3, glib
, clutter-gtk, clutter-gst, udev, gst_all_1, itstool, libgudev, vala
, appstream-glib, libtool, librsvg, gdk_pixbuf, gnome3, libxml2
, callPackage, nix-gitignore }@args:

let src = fetchTarball https://github.com/kierdavis/pout/archive/master.tar.gz;
in import "${src}/default.nix" args

