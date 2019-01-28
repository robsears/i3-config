#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Update the network info right away, because it may have changed
i3-msg "exec ${DIR}/network-info.sh"

# Create a terminal in workspace 3
i3-msg 'workspace "3: term", exec /usr/bin/terminator'

# Open Firefox to the support desk I use. This will automatically open in the
# main workspace, but I like to group it with Slack in the chat workspace. This
# will get fixed in a few seconds.
i3-msg 'exec /usr/bin/firefox https://secure.helpscout.net/dashboard'

# Open up apps that I use all the time: Atom, Slack, and Spotify.
# These will all automatically load in workspaces defined in ../config.
i3-msg 'exec /usr/bin/atom; exec /usr/bin/slack; exec /usr/bin/spotify'

# Open up Firefox in a new window (to keep it from being a new tab in the
# window containing the support desk app). This will open in the main workspace.
i3-msg 'exec /usr/bin/firefox --new-window http://gmail.com https://twist.com'

# Wait for everything to load, then move the Support Desk window to the chat space
sleep 7
i3-msg '[class="Firefox" title="Dashboard - OMC - Mozilla Firefox"] move to workspace "2: chat"'
