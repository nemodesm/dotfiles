#!/bin/sh

setxkbmap us
xrandr -o normal

xinput set-prop "PixArt Lenovo USB Optical Mouse" "libinput Natural Scrolling Enabled" 1 > /dev/null 2>&1
xinput set-prop "PixArt USB Optical Mouse" "libinput Natural Scrolling Enabled" 1 > /dev/null 2>&1
xinput set-prop "PixArt HP 125 USB Optical Mouse" "libinput Natural Scrolling Enabled" 1 > /dev/null 2>&1
xinput set-prop "Cherry USB Optical Mouse" "libinput Natural Scrolling Enabled" 1 > /dev/null 2>&1
xinput set-prop "Cherry USB Optical Mouse" "libinput AccelSpeed" "-1" > /dev/null 2>&1

alias copy="xsel -b"
