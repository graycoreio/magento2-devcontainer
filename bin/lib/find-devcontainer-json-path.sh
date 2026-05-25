#!/bin/bash

# find_devcontainer_json_path — locate the user's devcontainer.json config
# file (the IDE-consumed JSON).
#
# Checks the canonical location `.devcontainer/devcontainer.json` first,
# then any one-level subdirectory of `.devcontainer/` (for projects that
# stash multiple devcontainer flavors in named subfolders).
#
# A normal project layout looks like:
#   project/
#   ├── .devcontainer/
#   │   ├── devcontainer.json          ← this function
#   │   └── magento2-devcontainer/     ← find_magento2_devcontainer_dir
#
# Args:    none
# Stdout:  path to devcontainer.json (does NOT set DEVCONTAINER_JSON_PATH;
#          callers capture via `$( ... )`)
# Stderr:  selection prompt when multiple candidates exist; error on invalid pick
# Returns: 0 on success, 1 if no devcontainer.json found
find_devcontainer_json_path() {
    if [ -f ".devcontainer/devcontainer.json" ]; then
        echo ".devcontainer/devcontainer.json"
        return
    fi

    # Look for devcontainer.json in subdirectories
    local configs=()
    while IFS= read -r -d '' file; do
        configs+=("$file")
    done < <(find .devcontainer -mindepth 2 -maxdepth 2 -name "devcontainer.json" -print0 2>/dev/null)

    if [ ${#configs[@]} -eq 0 ]; then
        return 1
    elif [ ${#configs[@]} -eq 1 ]; then
        echo "${configs[0]}"
    else
        echo "Multiple devcontainer.json files found:" >&2
        for i in "${!configs[@]}"; do
            echo "  $((i+1))) ${configs[$i]}" >&2
        done
        read -p "Select a config (1-${#configs[@]}): " selection >&2
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#configs[@]} ]; then
            echo "${configs[$((selection-1))]}"
        else
            echo "Invalid selection." >&2
            return 1
        fi
    fi
}
