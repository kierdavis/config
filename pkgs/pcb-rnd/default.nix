{ stdenv, fetchsvn, pkgconfig, gtk2, bison, intltool, flex, netpbm, imagemagick, dbus, xlibsWrapper, mesa, shared_mime_info, tcl, tk, gnome2, pangox_compat, gd, xorg }:

stdenv.mkDerivation rec {
  name = "pcb-rnd-${version}";
  version = "svn-r${svnRev}";
  svnRev = "12445";

  src = fetchsvn {
    url = "svn://repo.hu/pcb-rnd/trunk";
    rev = svnRev;
    sha256 = "0scvh7cgm9yy8lsj77dwijs108a3yzdkqwggqhafvpkkwmb6w995";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ gtk2 bison intltool flex netpbm imagemagick dbus xlibsWrapper mesa tcl shared_mime_info tk gnome2.gtkglext pangox_compat gd xorg.libXmu ];

  meta = with stdenv.lib; {
    description = "Printed Circuit Board editor";
    homepage = http://pcb.geda-project.org/;
    maintainers = with maintainers; [ mog ];
    platforms = platforms.linux;
    license = licenses.gpl2;
  };
}
