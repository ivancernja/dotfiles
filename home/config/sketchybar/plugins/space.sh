#!/bin/bash
# $SELECTED is set by SketchyBar for items with associated_space.
# Clicking a workspace switches to it, using the cmd+N shortcut macOS now owns.
ACCENT=0xffb696f7
FG=0xffc9d3df
DIM=0xff71808f

if [ "$SENDER" = "mouse.clicked" ]; then
  index="${NAME##*.}"
  osascript -e "tell application \"System Events\" to key code $(
    case "$index" in 1) echo 18;; 2) echo 19;; 3) echo 20;; 4) echo 21;; 5) echo 23;; esac
  ) using command down" 2>/dev/null
  exit 0
fi

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=on \
                           background.color=0x33b696f7 \
                           icon.color=$ACCENT \
                           label.color=$FG
else
  sketchybar --set "$NAME" background.drawing=off \
                           icon.color=$DIM \
                           label.color=$DIM
fi
