#!/bin/bash

# which player to get data from (must support mpris), refer to playerctl's github page for more info
PLAYER="spotify"
# final output format (what shows up in ur panel). available values: $ARTIST, $TRACK, $ALBUM, $SONGLINK
OUTFORMAT="$ARTIST - $TRACK"