#!/bin/bash

# find_magento2_devcontainer_dir — locate the magento2-devcontainer support
# directory (this repo, typically checked out as a submodule under
# `.devcontainer/`).
#
# Candidates are validated by is_magento2_devcontainer_dir — it requires
# compose/ AND devcontainer.json.sample AND bin/init.sh together, so a
# random sibling folder with its own compose/ subdir won't false-match.
# If invoked from inside the support repo itself, returns cwd.
#
# Depends on:
#   - is_magento2_devcontainer_dir         (is-magento2-devcontainer-dir.sh)
#
# Args:    none
# Stdout:  path to the magento2-devcontainer support dir
# Stderr:  selection prompt when multiple candidates exist; error on invalid pick
# Returns: 0 on success, 1 if no folder found or user picks invalid index
find_magento2_devcontainer_dir() {
    # Check if we're being sourced from within the support repo itself
    if is_magento2_devcontainer_dir "."; then
        pwd
        return
    fi

    # Look for directories under .devcontainer/ matching the support-repo signature
    local folders=()
    while IFS= read -r -d '' dir; do
        if is_magento2_devcontainer_dir "$dir"; then
            folders+=("$dir")
        fi
    done < <(find .devcontainer -mindepth 1 -maxdepth 2 -type d -print0 2>/dev/null)

    if [ ${#folders[@]} -eq 0 ]; then
        return 1
    elif [ ${#folders[@]} -eq 1 ]; then
        echo "${folders[0]}"
    else
        echo "Multiple magento2-devcontainer directories found:" >&2
        for i in "${!folders[@]}"; do
            echo "  $((i+1))) ${folders[$i]}" >&2
        done
        read -p "Select a directory (1-${#folders[@]}): " selection >&2
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#folders[@]} ]; then
            echo "${folders[$((selection-1))]}"
        else
            echo "Invalid selection." >&2
            return 1
        fi
    fi
}
