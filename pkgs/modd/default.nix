{ buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "modd-${version}";
  version = "0.8";
  src = fetchFromGitHub {
    owner = "cortesi";
    repo = "modd";
    rev = "v${version}";
    sha256 = "1dmfpbpcvbx4sl4q1hwbfpalq1ml03w1cca7x40y18g570qk7aq5";
  };
  goPackagePath = "github.com/cortesi/modd";
  subPackages = [ "cmd/modd" ];
  goDeps = ./deps.nix;
}
