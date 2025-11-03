#!/usr/bin/env bash

# Organizes multiple monitors.
# This script uses xrandr to define the orientation of several monitors. xrandr
# is used to determine the output names. The variables below map those outputs
# to physical locations, and the `xrandr` command sets the appropriate mode and
# relative positions of the monitors.

LEFT="DP-5"
CENTER="DP-1"
RIGHT="HDMI-0"

# RIGHT screen is on HDMI-0, and to the right of CENTER. CENTER is on DP-1 and is on the right of LEFT. LEFT is on DP-5. All are 1920x1080:
xrandr --auto --output $RIGHT --mode 1920x1080 --right-of $CENTER --output $CENTER --mode 1920x1080 --right-of $LEFT --output $LEFT --mode 1920x1080
