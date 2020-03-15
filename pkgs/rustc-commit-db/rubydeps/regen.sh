#!/usr/bin/env nix-shell
#!nix-shell -p bundix -i bash
set -o errexit -o nounset -o pipefail

bundix --magic
