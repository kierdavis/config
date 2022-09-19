with import <nixpkgs> {};
mkShell {
  buildInputs = [ cue google-cloud-sdk kubectl talosctl terraform tfk8s ];
}
