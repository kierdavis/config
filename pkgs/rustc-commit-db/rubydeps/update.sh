#!/usr/bin/env nix-shell
#!nix-shell -p bundler bundix -i bash
set -o errexit -o nounset -o pipefail

bundler lock --update
bundix
