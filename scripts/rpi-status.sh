#!/usr/bin/env bash

# Get the status of the pihole
RPI_STATUS=$(curl -s http://uptime.pi/uptime)

# Get the directories involved:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATA="${DIR}/../data"

# Save the output
if [ -z "${RPI_STATUS}" ]; then
  echo "status:offline" > "${DATA}/pihole"
else
  echo "${RPI_STATUS}" | tr '|' '\n' > "${DATA}/pihole"
fi
