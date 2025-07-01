{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "tfreveal";
  version = "7dc8718bb7a2e9518cfeb676e75da356dd375566";
  src = fetchFromGitHub {
    owner = "breml";
    repo = pname;
    rev = version;
    hash = "sha256-S4365DZN5C/pvUtrWGrwA+Udtd/yK4J1X/KRE+xDgDU=";
  };
  vendorHash = "sha256-tvHRb6XaxSsxWRsGLzo2+OJyPML+6Vzx0HJ9uY/j9bg=";
}
