#!/usr/bin/env bash

# Get the directories involved:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATA="${DIR}/../data"

# Get the status of the pihole
RPI_STATUS=$(curl -s http://uptime.pi/uptime)

if [ $? -ne 0 ]; then
  RPI_STATUS=$(curl -s http://$RPI_IPV4/uptime)
fi

# Save the output
if [ -z "${RPI_STATUS}" ]; then
  echo "status:offline" > "${DATA}/pihole"
else
  echo "${RPI_STATUS}" | tr '|' '\n' > "${DATA}/pihole"
fi
