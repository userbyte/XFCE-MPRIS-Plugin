#!/bin/bash

# which player to get data from (must support mpris), refer to playerctl's github page for more info
PLAYER="spotify"
# final output format (what shows up in ur panel). available values: $STATUSCHAR, $ARTIST, $TRACK, $ALBUM, $SONGLINK
OUTFORMAT="[$STATUSCHAR] $ARTIST - $TRACK"
# image settings    - this stuff requires python, refer to the readme for instructions
IMGENABLE="true" # true or false, whether or not to enable showing song album cover
IMGSIZE="20" # image size in pixels, configurable so u can match it to your panel height