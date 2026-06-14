#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
PID_FILE="/tmp/wallpaper_loop.pid"

FILES=($(find "$WALLPAPER_DIR" -type f \( -iname \*.jpg -o -iname \*.png \)))
OPTIONS="Stop Loop\nStart Loop\n$(printf "%s\n" "${FILES[@]}")"
CHOICE=$(echo -e "$OPTIONS" | wofi --dmenu --prompt "Select Wallpaper:")

if [ -z "$CHOICE" ]; then
    exit 0
fi

set_wallpaper() {
    local img="$1"
    hyprctl hyprpaper preload "$img"
    hyprctl hyprpaper wallpaper ",$img"
    hyprctl hyprpaper unload unused
}

if [ "$CHOICE" == "Stop Loop" ]; then
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE")
        rm "$PID_FILE"
    fi
    
elif [ "$CHOICE" == "Start Loop" ]; then
    INTERVAL_OPTIONS="60\n300\n600\n1800\n3600"
    INTERVAL=$(echo -e "$INTERVAL_OPTIONS" | wofi --dmenu --prompt "Interval in seconds:")
    
    if ! [[ "$INTERVAL" =~ ^[0-9]+$ ]]; then
        INTERVAL=300
    fi

    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE")
    fi
    
    (
        while true; do
            for img in "${FILES[@]}"; do
                set_wallpaper "$img"
                sleep "$INTERVAL"
            done
        done
    ) &
    echo $! > "$PID_FILE"
    
else
    if [ -f "$PID_FILE" ]; then
        kill $(cat "$PID_FILE")
        rm "$PID_FILE"
    fi
    set_wallpaper "$CHOICE"
fi
