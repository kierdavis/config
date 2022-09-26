with import <nixpkgs> {};

let
  terraformWrapped = buildFHSUserEnv {
    name = "terraform";
    targetPkgs = pkgs: with pkgs; [
      ceph.lib
      terraform
    ];
    runScript = "terraform";
  };
in
mkShell {
  buildInputs = [
    cue
    google-cloud-sdk
    kubectl
    talosctl
    terraformWrapped
    tfk8s
  ];
}
