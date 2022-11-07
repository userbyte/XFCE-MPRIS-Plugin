#!/bin/bash

# which player to get data from (must support mpris), refer to playerctl's github page for more info
PLAYER="spotify"
# set PLAYER to auto for PRIOLIST to take effect
# comma-seperated list of players to try getting metadata from, from left to right: highest priority --> lowest priority
PRIOLIST="spotify,mpd,lollypop,amberol,vvave"
# final output format (what shows up in ur panel). available values: $STATUSCHAR, $ARTIST, $TRACK, $ALBUM, $SONGLINK
OUTFORMAT="[$STATUSCHAR] $ARTIST - $TRACK"
# image settings    - this stuff requires python, refer to the readme for instructions
IMGENABLE="true" # true or false, whether or not to enable showing song album cover
IMGSIZE="20" # image size in pixels, configurable so u can match it to your panel height