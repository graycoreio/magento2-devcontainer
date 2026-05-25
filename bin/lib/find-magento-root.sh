#!/bin/bash

# Locate the Magento root directory in a workspace, supporting both
# repo-root and monorepo layouts. The is_magento_root predicate decides
# whether a candidate directory is actually a Magento install.
#
# Depends on:
#   - is_magento_root                       (is-magento-root.sh)

# Find the Magento root directory. Supports two layouts:
#   1. Standard: $magento_root/.devcontainer (Magento at repo root)
#   2. Monorepo: $reporoot/.devcontainer with Magento in a subfolder
#
# Args:    $1 = search root (defaults to ".")
# Stdout:  path to the Magento root directory (does NOT set MAGENTO_ROOT —
#          callers capture via `$( ... )` or use get_magento_version)
# Stderr:  selection prompt when multiple installations exist; error on
#          invalid pick
# Returns: 0 on success, 1 if no Magento root found or invalid selection
find_magento_root() {
    local search_root="${1:-.}"

    # Check if Magento is at the search root (standard setup)
    if is_magento_root "$search_root"; then
        echo "$search_root"
        return
    fi

    # Search for Magento in subdirectories (monorepo setup)
    local magento_roots=()
    while IFS= read -r -d '' composer_file; do
        local dir=$(dirname "$composer_file")
        if is_magento_root "$dir"; then
            magento_roots+=("$dir")
        fi
    done < <(find "$search_root" -maxdepth 4 -name "composer.json" -print0 2>/dev/null)

    if [ ${#magento_roots[@]} -eq 0 ]; then
        return 1
    elif [ ${#magento_roots[@]} -eq 1 ]; then
        echo "${magento_roots[0]}"
    else
        echo "Multiple Magento installations found:" >&2
        for i in "${!magento_roots[@]}"; do
            echo "  $((i+1))) ${magento_roots[$i]}" >&2
        done
        read -p "Select Magento root (1-${#magento_roots[@]}): " selection >&2
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#magento_roots[@]} ]; then
            echo "${magento_roots[$((selection-1))]}"
        else
            echo "Invalid selection." >&2
            return 1
        fi
    fi
}
