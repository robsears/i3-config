#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Update the network info right away, because it may have changed
i3-msg "exec ${DIR}/network-info.sh"

# Create a terminal in workspace 3
i3-msg 'workspace "term"; exec /usr/bin/terminator'

# Open Firefox to the support desk I use. This will automatically open in the
# main workspace, but I like to group it with Slack in the chat workspace. This
# will get fixed in a few seconds.
i3-msg 'workspace "web"; exec /usr/bin/brave'

# Open up apps that I use all the time: Atom, Slack, and Spotify.
# These will all automatically load in workspaces defined in ../config.
i3-msg 'workspace "code"; exec /usr/bin/code; workspace "chat"; exec /usr/bin/slack; workspace "spotify"; exec /usr/bin/spotify'

# Open up Firefox in a new window (to keep it from being a new tab in the
# window containing the support desk app). This will open in the main workspace.
# i3-msg 'exec /usr/bin/brave --new-window http://gmail.com'

i3-msg 'workspace "protonmail"; exec /usr/bin/brave --new-window -incognito https://beta.protonmail.com/'

# Wait for everything to load, then move the Support Desk window to the chat space
sleep 7
#i3-msg '[class="Brave" title="Dashboard - OMC - Brave"] move to workspace "2: chat"'
#i3-msg '[class="Brave" title="Proton Account - Brave"] move to workspace "protonmail"'
