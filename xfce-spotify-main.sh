#!/bin/bash

# Script orignally made by macr1408 (https://github.com/macr1408), modified by userbyte (https://github.com/userbyte) to use playerctl instead of the Spotify API because I could't get it to work
# Made for non-commercial use

if ! pgrep -x spotify >/dev/null && ! pgrep -x chrome >/dev/null && ! pgrep -x firefox >/dev/null && ! pgrep -f lollypop >/dev/null
then
    echo "<txt></txt>"
    exit 1;
fi

CURRENTDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
CONFIGFILE="$CURRENTDIR/config.sh"
SONGFILE="$CURRENTDIR/current_song.json"
source $CONFIGFILE

# PLAYER="spotify" # grabbed from config

#FORMAT="{{ artist }} - {{ title }}"
FORMAT='{"title": "{{ title }}", "artist": "{{ artist }}", "album": "{{ album }}", "link": "{{ xesam:url }}", "arturl": "{{ mpris:artUrl }}"}'

PLAYERCTL_STATUS=$(playerctl --player=$PLAYER status 2>/dev/null)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    STATUS=$PLAYERCTL_STATUS
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
        playerctl --player=$PLAYER metadata --format "$FORMAT"
        STATUSCHAR="⏸"
    elif [ "$STATUS" = "No player is running"  ]; then
        echo "$STATUS"
        OUTFORMAT="(stopped)"
        STATUSCHAR="⏹"
    else
        playerctl --player=$PLAYER metadata --format "$FORMAT" > $SONGFILE
        STATUSCHAR="▶"
    fi
fi

ARTIST=$(jq -r '.artist' $SONGFILE)
TRACK=$(jq -r '.title' $SONGFILE)
ALBUM=$(jq -r '.album' $SONGFILE)
SONGLINK=$(jq -r '.link' $SONGFILE)
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
    IMGURL=$(jq -r '.arturl' $SONGFILE)
    if [ "$IMGURL" = "" ]
    then
        #echo "IMGURL is empty, using unknown artwork."
        IMGURL="file://$CURRENTDIR/unknown.png"
        /usr/bin/python3 $CURRENTDIR/imageresizer.py $CURRENTDIR $IMGURL $IMGSIZE
        IMG="<img>$CURRENTDIR/out.png</img>"
    else
        #echo "IMGURL is not empty W"
        /usr/bin/python3 $CURRENTDIR/imageresizer.py $CURRENTDIR $IMGURL $IMGSIZE
        IMG="<img>$CURRENTDIR/out.png</img>"
    fi
fi
if [ -n "$TRACK" ]
then
    echo "<txt>$OUTFORMAT</txt>"
    echo "<tool>$ALBUM</tool>"
    #echo "<bar>$TOTALPROGRESS</bar>"
    echo "<txtclick>xdg-open $SONGLINK</txtclick>"
    echo "$IMG"
else
    echo "<txt></txt>"
fi