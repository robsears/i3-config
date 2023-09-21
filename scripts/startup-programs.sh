#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Update the network info right away, because it may have changed
i3-msg "exec ${DIR}/network-info.sh"

# Create a terminal in workspace 3
i3-msg "workspace \"term\"; exec $(which terminator)"

# Launch brave.
i3-msg "workspace \"web\"; exec $(which brave)"

# Open up apps that I use all the time: VS Code, Slack, and Spotify.
# These will all automatically load in workspaces defined in ../config.
i3-msg "workspace \"code\"; exec $(which code); workspace \"chat\"; exec $(which slack); workspace \"spotify\"; exec $(which spotify)"

# Open up Firefox in a new window
i3-msg "exec $(which firefox) -p Personal"
