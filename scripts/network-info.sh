#!/usr/bin/env bash

# Get the public IPv4 address, write out to ~/.config/i3-data/public-ipv4.

DATA="${HOME}/.config/i3-data"

echo "public-ipv4: $(curl -s ipinfo.io/ip)" > "${DATA}/public-ipv4"
