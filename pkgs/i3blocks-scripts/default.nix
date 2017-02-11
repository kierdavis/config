{ stdenv, makeWrapper, gnused, bc, nvidia_x11 }:

stdenv.mkDerivation {
  name = "i3blocks-scripts";
  builder = ./builder.sh;
  buildInputs = [ makeWrapper ];
  srcDir = ./scripts;
  extraPath = builtins.concatStringsSep ":" [
    "${gnused}/bin"     # provides sed
    "${bc}/bin"         # provides bc
    "${nvidia_x11}/bin" # provides nvidia-smi
  ];
}
