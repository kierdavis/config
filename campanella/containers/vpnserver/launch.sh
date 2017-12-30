#!/bin/sh
docker run --rm --cap-add=net_admin --device=/dev/net/tun --publish 1194:1194/udp "$@" campanella-vpnserver
