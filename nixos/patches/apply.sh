#!/bin/sh
set -eu

if [ $(id -u) -ne 0 ]; then
  sudo $0
  exit $?
fi

nixpkgs="/etc/nixos/nixpkgs"
patches="/home/kier/config/nixos/patches"
upstream_repo="https://github.com/NixOS/nixpkgs-channels"
#upstream_branch="1e1472ed93e1256dfdac4908ae8edcb90ceff21c" # "upstream/nixos-unstable"
upstream_branch="51a83266d164195698f04468d90d2c6238ed3491" # "upstream/nixos-17.03"
patched_branch="kier"

mkdir -p $patches

if [ ! -e $nixpkgs ]; then
  # Clone repository
  echo "Cloning $upstream_repo to $nixpkgs..."
  git clone $upstream_repo $nixpkgs
  git -C $nixpkgs remote add upstream $upstream_repo
  git -C $nixpkgs branch $patched_branch
fi

# Update repository
echo "Fetching from upstream..."
git -C $nixpkgs fetch upstream

# Force $patched_branch to point at $upstream_branch
echo "Resetting branch $patched_branch to $upstream_branch..."
git -C $nixpkgs checkout $patched_branch
git -C $nixpkgs reset --hard $upstream_branch
git -C $nixpkgs clean -d --force

# Apply patches
for patch in $(find $patches -name '*.patch' | sort); do
  echo "Applying $patch"
  git -C $nixpkgs apply $patch
  # git -C $nixpkgs add $nixpkgs
  # git -C $nixpkgs commit --no-gpg-sign --all --message "[custom patch] $patch"
done

echo
echo "OK"
