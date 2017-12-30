{ pkgs ? import <nixpkgs> {} }:

pkgs.dockerTools.pullImage {
  imageName = "busybox";
  imageTag = "1.27.2";
  sha256 = "1w53ia9hdry6im4pcdqmjqsp5zawgjfdp5f5x7kvqivcpbpjbw99";
}
