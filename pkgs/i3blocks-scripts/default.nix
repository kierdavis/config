{ stdenv, lib, makeWrapper, gnused, bc, nvidia_x11, withNvidiaSupport ? true }:

stdenv.mkDerivation {
  name = "i3blocks-scripts";
  builder = ./builder.sh;
  buildInputs = [ makeWrapper ];
  srcDir = ./scripts;
  extraPath = lib.makeBinPath ([ gnused bc ] ++ lib.optional withNvidiaSupport nvidia_x11);
}
