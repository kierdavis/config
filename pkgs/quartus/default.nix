# To avoid permission errors when trying to use the USB Blaster JTAG cable, add the following
# to the udev rules (services.udev.extraRules on NixOS):
#
#   SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", GROUP="dialout", MODE="0666"

{ buildFHSUserEnv
, fetchurl
, stdenv
, writeShellScriptBin
, withModelsim ? true
, withHelp ? false
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

  lib = stdenv.lib;

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
    installerWrapperContents = stdenv.mkDerivation {
      name = "${name}-installer-wrapper-contents";
      phases = "buildPhase";
      buildPhase = ''
        runHook preBuild
        mkdir -p $out/bin
        echo '#!${stdenv.shell}' > $out/bin/entrypoint
        echo 'exec "${extracted}/QuartusSetupWeb-${version}.run" "$@"' >> $out/bin/entrypoint
        chmod +x $out/bin/entrypoint
        runHook postBuild
      '';
    };
    installerWrapper = buildFHSUserEnv {
      name = "${name}-installer-wrapper";
      targetPkgs = _: [ installerWrapperContents ];
      runScript = "entrypoint";
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

    # Since an FHS wrapper can only call one executable, we define a utility script to forward calls to any executable of our choice.
    entrypointScriptPkg = writeShellScriptBin "${name}-entrypoint" ''
      set -o errexit -o pipefail -o nounset
      prog_name=$1
      shift
      exec "${installationBinDir}/$prog_name" "$@"
    '';
    entrypointScript = "${entrypointScriptPkg}/bin/${entrypointScriptPkg.name}";

    # Create a wrapper around the Quartus executables.
    quartusWrapperContents = stdenv.mkDerivation {
      name = "${name}-wrapper-contents";
      phases = "buildPhase";
      buildPhase = ''
        runHook preBuild
        mkdir -p $out/bin
        ln -s ${entrypointScript} $out/bin/entrypoint
        runHook postBuild
      '';
    };
    quartusWrapper = buildFHSUserEnv {
      name = "${name}-wrapper";
      targetPkgs = _: [ quartusWrapperContents ];
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
      runScript = "entrypoint";
    };

    # Assemble a frontend that's useful to a user.
    frontendScriptPkg = writeShellScriptBin "${name}-frontend" ''
      set -o errexit -o pipefail -o nounset
      prog_name=$(basename $0)
      exec ${quartusWrapper}/bin/${quartusWrapper.name} $prog_name "$@"
    '';
    frontendScript = "${frontendScriptPkg}/bin/${frontendScriptPkg.name}";
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
