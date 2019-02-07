oldBuildNodePackage: oldAttrs:

let
  stdenv = (oldBuildNodePackage {
    name = null;
    packageName = null;
    version = null;
  }).stdenv;
in

oldBuildNodePackage (oldAttrs // {
  src = stdenv.mkDerivation {
    name = "mstream-src";
    phases = "unpackPhase patchPhase installPhase";
    src = oldAttrs.src;
    patches = [ ./fix-database-dirs.patch ];
    installPhase = ''
      runHook preInstall
      cp -R . $out
      runHook postInstall
    '';
  };
})
