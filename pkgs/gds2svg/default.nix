{ buildPerlPackage, fetchFromGitHub, fetchurl, perl, stdenv }:

let
  perl-gds2 = buildPerlPackage rec {
    name = "GDS2-3.34";
    src = fetchurl {
      url = "mirror://cpan/authors/id/S/SC/SCHUMACK/${name}.tar.gz";
      sha256 = "f94dbf7afe755389dcfeb70e24478efaf2c0be297b2f8207b7786a423949d23f";
    };
    meta = {
      homepage = https://metacpan.org/module/GDS2;
      license = stdenv.lib.licenses.unknown;
    };
  };

  perl-svg = buildPerlPackage rec {
    name = "SVG-2.78";
    src = fetchurl {
      url = "mirror://cpan/authors/id/M/MA/MANWAR/${name}.tar.gz";
      sha256 = "a665c1f18c0529f3da0f4b631976eb47e0f71f6d6784ef3f44d32fd76643d6bb";
    };
    meta = {
      description = "Perl extension for generating Scalable Vector Graphics (SVG) documents";
      license = with stdenv.lib.licenses; [ artistic1 gpl1Plus ];
    };
  };

in stdenv.mkDerivation {
  name = "gds2svg";
  src = fetchFromGitHub {
    owner = "christophmuellerorg";
    repo = "gds2svg";
    rev = "68287eadfe3d853903e30394819746467e359ea7";
    sha256 = "0j4v9sw55h70w5jfqlp1y04gb7jz3pzdr0klqq6njq2agxfb6js3";
  };
  propagatedBuildInputs = [ perl-gds2 perl-svg ];
  phases = "unpackPhase patchPhase installPhase";
  postPatch = ''
    sed -i 's,#!/usr/bin/perl,#!${perl}/bin/perl -I${perl-gds2}/lib/perl5/site_perl -I${perl-svg}/lib/perl5/site_perl,' gds2svg.pl
  '';
  installPhase = ''
    install -m 0755 -d $out/bin
    install -m 0755 gds2svg.pl $out/bin/gds2svg
  '';
}
