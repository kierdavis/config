{ stdenv, lib, fetchsvn }:

with lib;

let
  svnSources = import ./svn-sources.nix { inherit fetchsvn; };

  # SVN revision of the top-level repo.
  rev = svnSources.".".rev;

  # Returns a shell script that will overlay the contents of ${src}
  # onto $out/${reldest}.
  buildStep = reldest: src: ''
    dest=$out/${reldest}
    echo 'Placing ${src.url}@${src.rev} at '$dest
    mkdir -p $dest
    cp --recursive ${src}/* --target-directory=$dest
    # cp will copy the permissions from the source files in the Nix store, which are
    # all read-only. We may need to overlay later svn sources on top of this one, so
    # we should mark the directory as writeable to enable this.
    chmod -R +w $dest
  '';

  buildScript = concatStrings (mapAttrsToList buildStep svnSources);

in stdenv.mkDerivation rec {
  inherit rev;

  name = "pcb-rnd-source-${version}";
  version = "svn-r${rev}";

  phases = [ "buildPhase" ];
  buildPhase = buildScript;
}
