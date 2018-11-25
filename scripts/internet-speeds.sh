#!/usr/bin/env bash

# Check the speed of the internet.
# Requires speedtest-cli: https://github.com/sivel/speedtest-cli
# Returns:
#  ping:      The ping time in ms
#  bps-down:  The download speed in bits per second
#  bps-up:    The upload speed in bits per second
#
# Notes: The ping and ul/dl values will be floats.

speedtest-cli --csv | sed -r 's/.*,([\.0-9]{1,}),([\.0-9]{1,}),([\.0-9]{1,}),,([\.0-9]{5,})$/ping: \1\nbps-down: \2\nbps-up: \3/'
