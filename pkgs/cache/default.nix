{ stdenv, nix, writeScriptBin }:

writeScriptBin "cache" ''
  #!${stdenv.shell}
  cache=/mnt/nocturn/nix-cache
  secret_key=/etc/nix/nix-cache.sec
  ${nix}/bin/nix-push --dest $cache --bzip2 --key-file $secret_key $*
''
