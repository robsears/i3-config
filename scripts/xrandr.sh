#!/bin/bash

# Organizes multiple monitors.
# This script uses xrandr to define the orientation of several monitors. xrandr
# is used to determine the output names. The variables below map those outputs
# to physical locations, and the `xrandr` command sets the appropriate mode and
# relative positions of the monitors.

LEFT="DP-3"
CENTER="DP-5"
RIGHT="HDMI-0"

xrandr --auto --output $RIGHT --mode 1920x1080 --right-of $LEFT --output $LEFT --mode 1920x1080 --right-of $CENTER --output $CENTER --mode 1920x1080
