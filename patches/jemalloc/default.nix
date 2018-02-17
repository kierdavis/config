# https://github.com/NixOS/nixpkgs/pull/33260 is not yet available on the current release channel.
# Therefore we take the fixed version of the file and overwrite our current package set with it.
# From https://github.com/NixOS/nixpkgs/blob/03d78aea0d7ffc2091edd2bbc98124a7b2fd9934/pkgs/development/libraries/jemalloc/default.nix

{ stdenv, fetchurl,
  # jemalloc is unable to correctly detect transparent hugepage support on
  # ARM, and the default kernel ARMv6/7 kernel does not enable it, so we 
  # explicitly disable support
  thpSupport ? stdenv.system != "armv7l-linux" &&
               stdenv.system != "armv6l-linux" }:

stdenv.mkDerivation rec {
  name = "jemalloc-${version}";
  version = "4.5.0";

  src = fetchurl {
    url = "https://github.com/jemalloc/jemalloc/releases/download/${version}/${name}.tar.bz2";
    sha256 = "9409d85664b4f135b77518b0b118c549009dc10f6cba14557d170476611f6780";
  };

  # By default, jemalloc puts a je_ prefix onto all its symbols on OSX, which
  # then stops downstream builds (mariadb in particular) from detecting it. This
  # option should remove the prefix and give us a working jemalloc.
  configureFlags = stdenv.lib.optional stdenv.isDarwin "--with-jemalloc-prefix="
                   ++ stdenv.lib.optional (!thpSupport) "--disable-thp";

  doCheck = true;


  meta = with stdenv.lib; {
    homepage = http://jemalloc.net;
    description = "General purpose malloc(3) implementation";
    longDescription = ''
      malloc(3)-compatible memory allocator that emphasizes fragmentation
      avoidance and scalable concurrency support.
    '';
    license = licenses.bsd2;
    platforms = platforms.all;
    maintainers = with maintainers; [ wkennington ];
  };
}
