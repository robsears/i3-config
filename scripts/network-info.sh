#!/usr/bin/env bash

# Get the local

# The device to check.
# TODO: Parameterize this?
DEV=wlp3s0

# Output the network information:
echo "public-ipv4: $(curl -s ipinfo.io/ip)"
echo "local-ipv4: $(ip addr show dev ${DEV} | grep 'inet ' | sed -r 's/.*inet ([\.0-9]{1,})\/.*/\1/')"
