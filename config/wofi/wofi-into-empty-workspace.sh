#!/usr/bin/env bash

# Use wofi to select an app from the "drun" menu (all installed apps)
selected_app=$(wofi --show drun -a -i)

# Only proceed if something was selected
if [[ -n "$selected_app" ]]; then
    # Switch to empty workspace first
    hyprctl dispatch workspace emptym

    # Launch the app in the current (empty) workspace
    hyprctl dispatch exec "$selected_app"
fi