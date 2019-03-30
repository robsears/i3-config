#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Update the network info right away, because it may have changed
i3-msg "exec ${DIR}/network-info.sh"

# Create a terminal in workspace 3
i3-msg 'workspace "3: term", exec /usr/bin/terminator'

# Open Firefox to the support desk I use. This will automatically open in the
# main workspace, but I like to group it with Slack in the chat workspace. This
# will get fixed in a few seconds.
i3-msg 'exec /usr/bin/firefox https://gmail.com https://protonmail.com'

# Open up apps that I use all the time: Atom, Libreoffice, and Spotify.
# These will all automatically load in workspaces defined in ../config.
i3-msg 'exec /usr/bin/atom'
i3-msg 'workspace 2, exec /usr/bin/libreoffice'
i3-msg 'exec /usr/bin/spotify'
