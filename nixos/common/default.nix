{
  imports = [
    ./apps.nix
    ./boot.nix
    ./env.nix
    ./fs.nix
    ./locale.nix
    ./net.nix
    ./nix.nix
    ./options.nix
    ./services.nix
    ./users.nix
  ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "18.09";

  # Root SSL cert.
  security.pki.certificateFiles = [ ../../ssl-ca.pem ];
}
