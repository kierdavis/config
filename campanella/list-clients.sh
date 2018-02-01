#!/bin/sh

# Doesn't work at the moment - either need to fix the openvpn bug or downgrade openvpn
# on the server.

set -o errexit -o pipefail -o nounset

echo "status 3" | nc -N campanella-vpnserver 9000 | grep '^ROUTING_TABLE' | cut -f 3,2
