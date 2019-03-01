# Based on https://github.com/cliffordwolf/picorv32/blob/master/shell.nix

{ bison, curl, expat, fetchFromGitHub, flex, gawk, gmp, gperf, libmpc, mpfr, stdenv, texinfo
, arch ? "rv32i" }:

let
  riscv-toolchain-ver = "8.2.0";
  riscv-src = fetchFromGitHub {
    owner  = "riscv";
    repo   = "riscv-gnu-toolchain";
    rev    = "bb41926cb5a62e6cbe4b659ded6ff52c70b2baf1";
    sha256 = "1j9y3ai42xzzph9rm116sxfzhdlrjrk4z0v4yrk197j72isqyxb0";
    fetchSubmodules = true;
  };

in stdenv.mkDerivation rec {
  name    = "riscv-${arch}-toolchain-${version}";
  version = "${riscv-toolchain-ver}-${builtins.substring 0 7 src.rev}";
  src     = riscv-src;

  configureFlags   = ["--with-arch=${arch}"];
  installPhase     = ":"; # 'make' installs on its own
  hardeningDisable = [ "all" ];
  enableParallelBuilding = true;

  # Stripping/fixups break the resulting libgcc.a archives, somehow.
  # Maybe something in stdenv that does this...
  #dontStrip = true;
  #dontFixup = true;

  nativeBuildInputs = [ curl gawk texinfo bison flex gperf ];
  buildInputs = [ libmpc mpfr gmp expat ];
}
