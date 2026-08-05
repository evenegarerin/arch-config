#!/usr/bin/env zsh

local cwd_file=$(mktemp)
yazi --cwd-file "$cwd_file"
if new_cwd="$(<"$cwd_file")" && [ -n "$new_cwd" ] && [ "$new_cwd" != "$PWD" ]; then

    local selection_file=$(mktemp)

    yazi $VSCODE_WORKSPACE_LOCATION --chooser-file "$selection_file"

    workspace_file=$(<"$selection_file")
    rm -f "$selection_file"

    if [[ -z "$workspace_file" ]]; then
        zsh -ic "code $new_cwd"
    else
        jq --arg cwd "$new_cwd" '.folders = [{ "path": $cwd }]' "$workspace_file" > "$workspace_file.tmp" && mv "$workspace_file.tmp" "$workspace_file"

        zsh -ic 'code "$1"' _ "$workspace_file"
    fi

fi
rm -f -- "$cwd_file"