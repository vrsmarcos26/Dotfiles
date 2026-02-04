#!/bin/sh

if [ "$DESKTOP_SESSION" = "zorin-xorg" ]; then 
   sleep 10s
   killall conky
   cd "$HOME/.conky/Gotham"
   conky -c "$HOME/.conky/Gotham/Gotham" &
   exit 0
fi
