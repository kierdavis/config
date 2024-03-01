# To avoid permission errors when trying to use the USB Blaster JTAG cable, add the following
# to the udev rules (services.udev.extraRules on NixOS):
#
#   SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0666"

{ fetchurl
, fetchzip
, lib
, stdenv
, writeShellScript
, withModelsim ? true
, withHelp ? true
, withArriaSupport ? false
, withCycloneVSupport ? false
, withCycloneLegacySupport ? true
, withMAXSupport ? false
}:

let
  release = "13.0sp1";
  revision = "232";
  version = "13.0.1.${revision}";
  name = "quartus-${version}";

  # This derivation no longer works with the latest nixpkgs.
  oldNixpkgs = import (fetchzip {
    name = "${name}-nixpkgs";
    url = "https://releases.nixos.org/nixos/22.11/nixos-22.11.4773.ea4c80b39be4/nixexprs.tar.xz";
    hash = "sha256-wZ8ktcD7KUPzOMSQXbbuvM2/YS5+sihPqnNymFQ58Mg=";
  }) {};

  attrs = rec {
    # Download the installer tarball.
    # A copy of this is archived at bonito:/data/archive/misc/quartus-13.0sp1-linux.tar.bz2
    tarball = fetchurl {
      url = "http://download.altera.com/akdlm/software/acdsinst/${release}/${revision}/ib_tar/Quartus-web-${version}-linux.tar";
      sha256 = "0k7bpky31zh0gsyf2vphrdg73ji0bjpxwgrlc9wnbi39zczx1i6s";
    };

    # Extract the installer tarball.
    components = [ "QuartusSetupWeb-${version}.run" ]
      ++ lib.optional withModelsim "ModelSimSetup-${version}.run"
      ++ lib.optional withHelp "QuartusHelpSetup-${version}.run"
      ++ lib.optional withArriaSupport "arria_web-${version}.qdz"
      ++ lib.optional withCycloneVSupport "cyclonev-${version}.qdz"
      ++ lib.optional withCycloneLegacySupport "cyclone_web-${version}.qdz"
      ++ lib.optional withMAXSupport "max_web-${version}.qdz";
    extracted = stdenv.mkDerivation {
      name = "${name}-extracted";
      phases = "installPhase";
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        tar -vx -C $out -f ${tarball} ${builtins.concatStringsSep " " (map (m: "components/${m}") components)}
        mv $out/components/* $out
        rmdir $out/components
        chmod +x $out/*.run
        runHook postInstall
      '';
    };

    # Create a wrapper around the installer that runs it in an FHS-compatible environment.
    installerWrapper = oldNixpkgs.buildFHSUserEnv {
      name = "${name}-installer-wrapper";
      runScript = "${extracted}/QuartusSetupWeb-${version}.run";
    };

    # Run the installer to create an installation of the Quartus software.
    installation = stdenv.mkDerivation {
      name = "${name}-installation";
      phases = "installPhase";
      installPhase = ''
        runHook preInstall
        ${installerWrapper}/bin/${installerWrapper.name} --unattendedmodeui minimal --mode unattended --installdir $out
        runHook postInstall
      '';
    };
    installationBinDir = "${installation}/quartus/bin";

    # Create a wrapper around the Quartus executables.
    quartusWrapper = oldNixpkgs.buildFHSUserEnv {
      name = "${name}-wrapper";
      multiPkgs = pkgs: with pkgs; [
        fontconfig
        freetype
        libpng12
        xorg.libICE
        xorg.libSM
        xorg.libX11
        xorg.libXext
        xorg.libXrender
        zlib
      ];
      runScript = oldNixpkgs.writeShellScript "${name}-entrypoint" ''
        prog_name=$1
        shift
        exec "${installationBinDir}/$prog_name" "$@"
      '';
    };

    # Assemble a frontend that's useful to a user.
    frontendScript = writeShellScript "${name}-frontend" ''
      set -o errexit -o pipefail -o nounset
      prog_name=$(basename $0)
      exec ${quartusWrapper}/bin/${quartusWrapper.name} $prog_name "$@"
    '';
    quartus = stdenv.mkDerivation {
      inherit name;
      phases = "buildPhase";
      buildPhase = ''
        runHook preBuild
        mkdir -p $out/bin
        for name in $(ls ${installationBinDir}); do
          ln -s ${frontendScript} $out/bin/$name
        done
        runHook postBuild
      '';
    };
  };

in attrs.quartus // attrs
