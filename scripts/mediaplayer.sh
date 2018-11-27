#!/usr/bin/env bash

# Linux controls for a media player. Currently this script only targets Spotify,
# but could theoretically be adapted to support a variety of media players.

# Toggle the playback state between play and pause
play_pause_toggle() {
  dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.PlayPause
}

# Jumps to the start of the current song or the previous song, based on playback
# position
previous_song() {
  dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Previous
}

# Jumps to the next song
next_song() {
  dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Next
}

# Increase the master volume by 2dB
volume_up() {
  amixer -c 0 set Master 2db+
}

# Decrease the master volume by 2dB
volume_down() {
  amixer -c 0 set Master 2db-
}

# Mute or unmute the *system* volume.
# Muting the master channel mutes all the other channels, but unmuting master
# leaves everything else muted. So unmuting requires iterating over all the
# sound channels and unmuting them one at a time. Lame.
mute_toggle() {
  if [ ! -z "$(amixer -c 0 get Master | grep dB | egrep '\[on\]')" ]; then
    amixer -c 0 set Master mute &> /dev/null
  else
    amixer -c 0 set Master   unmute &> /dev/null
    amixer -c 0 set Front    unmute &> /dev/null
    amixer -c 0 set Surround unmute &> /dev/null
    amixer -c 0 set Center   unmute &> /dev/null
    amixer -c 0 set LFE      unmute &> /dev/null
    amixer -c 0 set Side     unmute &> /dev/null
  fi
}

case "$1" in
"play" | "pause" | "toggle")
  play_pause_toggle
  ;;
"previous")
  previous_song
  ;;
"next")
  next_song
  ;;
"volume_up")
  volume_up
  ;;
"volume_down")
  volume_down
  ;;
"volume_mute")
  mute_toggle
  ;;
esac
