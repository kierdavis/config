{ python3Packages }:

python3Packages.buildPythonApplication {
  pname = "nix-channel-proxy";
  version = "0.1";
  src = ./src;
}
