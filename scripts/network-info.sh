#!/usr/bin/env bash

# Get the network addresses for a given interface, write out to ../data/public_ipv4.

NETWORK=$(ip route | grep default | head -n1 | tr ' ' ',' | sed -r 's/^(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+),(.+)$/\3,\9,\5/')

LOCAL_IPV4=$(echo $NETWORK | sed -r 's/^(.+),(.+),(.+)$/\2/')
DEV=$(echo $NETWORK | sed -r 's/^(.+),(.+),(.+)$/\3/')
WIFI_NAME=$(iwgetid -r)


# Get the directories involved:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATA="${DIR}/../data"

# Output the network information:
echo "public-ipv4: $(curl -s ipinfo.io/ip)" > "${DATA}/public-ipv4"
echo "local-ipv4: $LOCAL_IPV4" >> "${DATA}/public-ipv4"
if [ -z "${WIFI_NAME}" ]; then
  if [ -z "${LOCAL_IPV4}" ]; then
    echo "LAN: Disconnected" > "${DATA}/network"
  else
    echo "LAN: Connected" > "${DATA}/network"
  fi
else
  echo "WAN: ${WIFI_NAME}" > "${DATA}/network"
fi
