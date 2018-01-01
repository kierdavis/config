#!/bin/sh

set -o errexit -o pipefail -o nounset

echo "status 3" | nc -N campanella-vpnserver 9000 | grep '^ROUTING_TABLE' | cut -f 3,2
