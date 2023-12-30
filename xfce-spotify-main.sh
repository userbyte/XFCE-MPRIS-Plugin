#!/bin/bash

# Script orignally made by macr1408 (https://github.com/macr1408), modified by userbyte (https://github.com/userbyte) to avoid using the Spotify Web API
# Made for non-commercial use

CURRENTDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
CONFIGFILE="$CURRENTDIR/config.sh"
if [ "$XDG_CACHE_HOME" = "" ]
then
    CACHEDIR=$CURRENTDIR/cache
else
    mkdir -p $XDG_CACHE_HOME/XFCE-Spotify-Plugin
    CACHEDIR=$XDG_CACHE_HOME/XFCE-Spotify-Plugin
fi
# SONGFILE="$CACHEDIR/current_song.json"

# get the first MPRIS player found on dbus
PLAYER=$(dbus-send --print-reply --dest=org.freedesktop.DBus  /org/freedesktop/DBus org.freedesktop.DBus.ListNames | grep -oP 'org.mpris.MediaPlayer2.*' | sed 's/"//')
PLAYER=$(echo $PLAYER | sed s/\ .*//)

if [ -z "$PLAYER" ]; then
    echo "No player running"
    echo "<txt></txt>"
    exit 1;
fi

PLAYER_STATUS=$(dbus-send --print-reply --dest=$PLAYER /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:PlaybackStatus)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    STATUS=$PLAYER_STATUS
else
    STATUS="No player is running"
fi

if [ "$1" == "--status" ]; then
    echo "$STATUS"
else
    if [ "$STATUS" = "Stopped" ]; then
        echo "No music is playing"
        OUTFORMAT="(stopped)"
        STATUSCHAR="⏹"
    elif [ "$STATUS" = "Paused"  ]; then
        METADATA=$(dbus-send --print-reply --dest=$PLAYER /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata)
        STATUSCHAR="⏸"
    elif [ "$STATUS" = "No player is running"  ]; then
        echo "$STATUS"
        OUTFORMAT="(stopped)"
        STATUSCHAR="⏹"
    else
        METADATA=$(dbus-send --print-reply --dest=$PLAYER /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:org.mpris.MediaPlayer2.Player string:Metadata)
        STATUSCHAR="▶"
    fi
fi

ARTIST=$(echo $METADATA | grep -oP 'xesam:artist.*' | sed 's/xesam:artist" variant array \[ string //' | awk -F \" '{print $2}')
TRACK=$(echo $METADATA | grep -oP 'xesam:title.*' | sed 's/xesam:title" variant string//' | awk -F \" '{print $2}')
ALBUM=$(echo $METADATA | grep -oP 'xesam:album.*' | sed 's/xesam:album" variant string//' | awk -F \" '{print $2}')
SONGLINK=$(echo $METADATA | grep -oP 'xesam:url.*' | sed 's/xesam:url" variant string//' | awk -F \" '{print $2}')

## cant get current progress from spotify metadata for some reason, commenting this out cuz not work. but leaving it in incase i wanna fix it in the future
#CURRENTPROGRESS=$(jq -r '.curprog' $SONGFILE) 
#CURPROGSECS=$(echo $CURRENTPROGRESS | awk -F: '{ print ($1 * 60) + ($2)}') # converts MM:SS to seconds
#CURPROGMILSECS=$(echo $((PSECS * 1000))) # converts seconds to milliseconds
#CURRENTPROGRESS=$(expr $CURPROGMILSECS \* 100)
#TOTALPROGRESS=$(jq -r '.totalprog' $SONGFILE)
#TOTALPROGSECS=$(echo $TOTALPROGRESS | awk -F: '{ print ($1 * 60) + ($2)}') # converts MM:SS to seconds
#TOTALPROGMILSECS=$(echo $((PSECS * 1000))) # converts seconds to milliseconds
#TOTALPROGRESS=$(expr $TOTALPROGMILSECS \* 100)
#TOTALPROGRESS=$(expr $CURRENTPROGRESS / $TOTALPROGRESS )

source $CONFIGFILE
if [ "$IMGENABLE" = "true" ]
then
    #echo "image enabled"
    IMGURL=$(echo $METADATA | grep -oP 'mpris:artUrl.*' | sed 's/mpris:artUrl" variant string//' | awk -F \" '{print $2}')
    if [ "$IMGURL" = "" ]
    then
        #echo "IMGURL is empty, using unknown artwork."
        IMGURL="file://$CURRENTDIR/unknown.png"
        /usr/bin/python3 $CURRENTDIR/imageresizer.py $CACHEDIR "$IMGURL" $IMGSIZE
        IMG="<img>$CACHEDIR/out.png</img>"
    else
        #echo "IMGURL is not empty W"
        /usr/bin/python3 $CURRENTDIR/imageresizer.py $CACHEDIR "$IMGURL" $IMGSIZE
        IMG="<img>$CACHEDIR/out.png</img>"
    fi
fi
OUTFORMAT=${OUTFORMAT:0:LENGTH_LIMIT}
if [ -n "$TRACK" ]
then
    echo "<txt>$OUTFORMAT</txt>"
    echo "<tool>$HOVERFORMAT</tool>"
    #echo "<bar>$TOTALPROGRESS</bar>"
    echo "<txtclick>xdg-open $SONGLINK</txtclick>"
    echo "$IMG"
else
    echo "<txt></txt>"
fi