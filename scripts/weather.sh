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

# The .weather-api file should contain the OpenWeatherMap API key, which is in
#the .gitignore file so we don't need to commit it to source control.
curl -s "https://api.openweathermap.org/data/2.5/weather?lat=41.2864&lon=-96.2345&appid=$(cat ./.weather-api)&units=imperial" | jq -r '"\(.main.feels_like)°F @ \(.main.humidity)%"'  > "${DATA}/weather"
