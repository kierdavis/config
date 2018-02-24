#!/bin/sh
set -o errexit -o pipefail -o nounset
$(nix-build --no-out-link -A geogaddi.config.system.build.docker.deployScript)/bin/deploy-geogaddi "$@"
