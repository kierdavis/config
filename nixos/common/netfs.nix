{ config, lib, pkgs, ... }:

{
  fileSystems."/net/campanella" = {
    device = "campanella-nfsserver:/";
    fsType = "nfs";
    options = [
      "vers=4"  # NFS version 4
    ];
  };
}
