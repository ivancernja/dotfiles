#!/bin/bash
read -r percent charging <<<"$(pmset -g batt | awk '/%/ {gsub(/[%;]/,"",$3); print $3, $4}')"
case "$charging" in
  charging|AC) icon="󰂄" ;;
  *) if   [ "$percent" -gt 80 ]; then icon="󰁹"
     elif [ "$percent" -gt 60 ]; then icon="󰂀"
     elif [ "$percent" -gt 40 ]; then icon="󰁾"
     elif [ "$percent" -gt 20 ]; then icon="󰁼"
     else icon="󰁺"; fi ;;
esac
colour=0xffc9d3df
[ "$percent" -le 20 ] && [ "$charging" != "charging" ] && colour=0xffff7ed1
sketchybar --set "$NAME" icon="$icon" icon.color=$colour label="${percent}%"
