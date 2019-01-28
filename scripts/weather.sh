#!/usr/bin/env bash

# This script polls wttr.in to get the local weather. Called without defaults,
# it will determine your rough location based on IP address, and return
# weather information from your area.
#
# At present, the script simply grabs the current temperature and writes it
# to the cache.

# Get the directories involved:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATA="${DIR}/../data"

# Cache the weather information:
echo "$(curl -s 'wttr.in/?1QT' | grep -m1 '°F' | sed -r 's/.* (-?[0-9]+)-?.*/\1/')" > "${DATA}/weather"
