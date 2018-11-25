#!/usr/bin/env bash

# Get the network addresses for a given interface, write out to ../data/public_ipv4.

# The device to check.
# TODO: Parameterize this?
DEV=wlp3s0

# Get the directories involved:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATA="${DIR}/../data"

# Output the network information:
echo "public-ipv4: $(curl -s ipinfo.io/ip)" > "${DATA}/public-ipv4"
echo "local-ipv4: $(ip addr show dev ${DEV} | grep 'inet ' | sed -r 's/.*inet ([\.0-9]{1,})\/.*/\1/')" >> "${DATA}/public-ipv4"
