#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Update the network info right away, because it may have changed
i3-msg "exec ${DIR}/network-info.sh"

# Create a terminal in workspace 3
i3-msg 'workspace "3: term", exec /usr/bin/terminator'

# Oen up a browser to my email client
i3-msg 'exec /usr/bin/brave https://protonmail.com'

# Open up apps that I use all the time: Atom, Libreoffice, and Spotify.
# These will all automatically load in workspaces defined in ../config.
i3-msg 'exec /usr/bin/atom'
i3-msg 'workspace "2: budget", exec /usr/bin/gnucash'
i3-msg 'exec /usr/bin/spotify'
