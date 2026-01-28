#!/bin/bash

# Shared devcontainer detection utilities
# Source this file from other scripts:
#   source "$(dirname "$0")/lib/detect-devcontainer.sh"

# Find the magento2-devcontainer folder within .devcontainer/
# Looks for a folder containing compose/ directory
find_devcontainer_folder() {
    # Check if we're being sourced from within the devcontainer repo itself
    if [ -d "compose" ] && [ -f "devcontainer.json.sample" ]; then
        pwd
        return
    fi

    # Look for folders in .devcontainer that contain compose/
    local folders=()
    while IFS= read -r -d '' dir; do
        if [ -d "$dir/compose" ]; then
            folders+=("$dir")
        fi
    done < <(find .devcontainer -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)

    if [ ${#folders[@]} -eq 0 ]; then
        return 1
    elif [ ${#folders[@]} -eq 1 ]; then
        echo "${folders[0]}"
    else
        echo "Multiple devcontainer folders found:" >&2
        for i in "${!folders[@]}"; do
            echo "  $((i+1))) ${folders[$i]}" >&2
        done
        read -p "Select a folder (1-${#folders[@]}): " selection >&2
        if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#folders[@]} ]; then
            echo "${folders[$((selection-1))]}"
        else
            echo "Invalid selection." >&2
            return 1
        fi
    fi
}

# Find devcontainer.json - check default location first, then subdirectories
# Sets DEVCONTAINER_JSON variable on success
find_devcontainer_json() {
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

# Detect devcontainer's configured Magento version from devcontainer.json
# This is the version the devcontainer is set up for (compose file selection)
# Usage: detect_devcontainer_magento_version "$DEVCONTAINER_JSON"
detect_devcontainer_magento_version() {
    local config_file="$1"

    # Try auto-detection with any folder name
    local version
    version=$(grep -oP '[^"/]+/compose/\K[0-9]+\.[0-9]+\.[0-9]+(?=/docker-compose\.yml)' "$config_file" | head -1)

    if [ -z "$version" ]; then
        echo "Could not auto-detect Magento version from $config_file" >&2
        echo "Expected a dockerComposeFile path like: <folder>/compose/2.4.6/docker-compose.yml" >&2
        echo "" >&2
        read -p "Enter the path to your magento2-devcontainer folder (e.g., magento2-devcontainer): " devcontainer_folder >&2

        if [ -z "$devcontainer_folder" ]; then
            echo "Error: No folder path provided." >&2
            return 1
        fi

        version=$(grep -oP "${devcontainer_folder}/compose/\K[0-9]+\.[0-9]+\.[0-9]+" "$config_file" | head -1)

        if [ -z "$version" ]; then
            echo "Error: Could not find Magento version using folder '$devcontainer_folder'" >&2
            return 1
        fi
    fi

    echo "$version"
}

# Find the Magento root directory
# Supports two layouts:
#   1. Standard: $magento_root/.devcontainer (Magento at repo root)
#   2. Monorepo: $reporoot/.devcontainer with Magento in a subfolder
# Usage: find_magento_root [search_root]
# Sets: MAGENTO_ROOT
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

# Check if a directory is a Magento root
# Usage: is_magento_root "/path/to/dir"
is_magento_root() {
    local dir="$1"

    # Must have composer.json
    [ -f "$dir/composer.json" ] || return 1

    # Check for Magento package in composer.json or composer.lock
    if [ -f "$dir/composer.lock" ]; then
        grep -q '"magento/product-\(community\|enterprise\)-edition"' "$dir/composer.lock" && return 0
    fi

    grep -q '"magento/product-\(community\|enterprise\)-edition"' "$dir/composer.json" && return 0

    return 1
}

# Detect user's actual Magento version from composer.json or composer.lock
# This is the version of Magento installed in the project
# Usage: detect_project_magento_version [magento_root]
detect_project_magento_version() {
    local magento_root="${1:-.}"
    local version=""

    # Try composer.lock first (more accurate - actual installed version)
    if [ -f "$magento_root/composer.lock" ]; then
        # Look for magento/product-community-edition or magento/product-enterprise-edition
        version=$(grep -oP '"name":\s*"magento/product-(community|enterprise)-edition".*?"version":\s*"\K[0-9]+\.[0-9]+\.[0-9]+' "$magento_root/composer.lock" | head -1)

        # If that didn't work, try a different pattern (version before name)
        if [ -z "$version" ]; then
            version=$(grep -A5 '"magento/product-\(community\|enterprise\)-edition"' "$magento_root/composer.lock" | grep -oP '"version":\s*"\K[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        fi
    fi

    # Fall back to composer.json (required version, may be a constraint)
    if [ -z "$version" ] && [ -f "$magento_root/composer.json" ]; then
        version=$(grep -oP '"magento/product-(community|enterprise)-edition":\s*"\K[0-9]+\.[0-9]+\.[0-9]+' "$magento_root/composer.json" | head -1)
    fi

    if [ -z "$version" ]; then
        return 1
    fi

    echo "$version"
}

# Load devcontainer config and detect version
# Sets: DEVCONTAINER_JSON, MAGENTO_VERSION
load_devcontainer_config() {
    DEVCONTAINER_JSON=$(find_devcontainer_json)

    if [ -z "$DEVCONTAINER_JSON" ] || [ ! -f "$DEVCONTAINER_JSON" ]; then
        echo "Error: No devcontainer.json found."
        echo "Please run bin/init.sh first to initialize your devcontainer."
        return 1
    fi

    echo "Using config: $DEVCONTAINER_JSON" >&2

    MAGENTO_VERSION=$(detect_devcontainer_magento_version "$DEVCONTAINER_JSON")

    if [ -z "$MAGENTO_VERSION" ]; then
        return 1
    fi

    echo "Detected devcontainer Magento version: $MAGENTO_VERSION" >&2
}

# Load project's Magento root and version
# Sets: MAGENTO_ROOT, PROJECT_MAGENTO_VERSION
# Usage: load_project_magento_version [search_root]
load_project_magento_version() {
    local search_root="${1:-.}"

    MAGENTO_ROOT=$(find_magento_root "$search_root")

    if [ -z "$MAGENTO_ROOT" ]; then
        echo "Could not find Magento installation" >&2
        return 1
    fi

    echo "Found Magento root: $MAGENTO_ROOT" >&2

    PROJECT_MAGENTO_VERSION=$(detect_project_magento_version "$MAGENTO_ROOT")

    if [ -z "$PROJECT_MAGENTO_VERSION" ]; then
        echo "Could not detect Magento version from composer.json/composer.lock" >&2
        return 1
    fi

    echo "Detected project Magento version: $PROJECT_MAGENTO_VERSION" >&2
}