# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff.

{config, pkgs, ...}:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    #<nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  services.openssh.enable = true;
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCr5oNVuZMYi1SwOUpIt13uhfSMzpP1e4g7WLjQJPa+vq8zOD2+ryHJgLbN+lw73ZQOVlSc1DZ4aA5DFF9SdPXdIct8hWw5DBqktO2vO7w7i7V68RrsGwcxHfMtbA7kfm1plO8tCcoP3IuWFONysowOhU0CKzwfsvnHex6s+t5GE6Y4KK+aFpzrqRkP2VnkK0nMP+2jeH4AMNEIZg1scO7BCFZZYeBPNLdT3tbnH+z6BPHr1CpT2iEaZEKsjGUPLdoqrXC2fqSFn8PJRCYfRAt3dxV1lQbZ/dt2sUZgzBz9XRhp5WPzWhRv6CVx2DFD3TnLkjQoC/7sHA6NRYJVI5b3 kier@coloris"
  ];

  networking = {
    usePredictableInterfaceNames = false;
    interfaces.eth3.ipv4.addresses = [{
      address = "192.168.1.222";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" ];
    firewall.allowedTCPPorts = [ 22 ];
  };
}
