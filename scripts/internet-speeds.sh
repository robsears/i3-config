#!/usr/bin/env bash

# Check the speed of the internet, write it out to ../data/internet-speeds
# Requires speedtest-cli: https://github.com/sivel/speedtest-cli
# Returns:
#  ping:      The ping time in ms
#  bps-down:  The download speed in bits per second
#  bps-up:    The upload speed in bits per second
#
# Notes: The ping and ul/dl values will be floats.

# Get the directories involved:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DATA="${DIR}/../data"

speedtest-cli --csv | sed -r 's/.*,([\.0-9]{1,}),([\.0-9]{1,}),([\.0-9]{1,}),,([\.0-9]{5,})$/ping: \1\nbps-down: \2\nbps-up: \3/' > "${DATA}/internet-speeds"
