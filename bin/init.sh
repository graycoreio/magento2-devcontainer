#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/detect-devcontainer.sh"

## Find the devcontainer folder
DEVCONTAINER_FOLDER=$(find_devcontainer_folder)

if [ -z "$DEVCONTAINER_FOLDER" ]; then
    echo "Error: Could not find magento2-devcontainer folder in .devcontainer/"
    echo "Ensure you have cloned the magento2-devcontainer repo as a submodule."
    exit 1
fi

FOLDER_NAME=$(basename "$DEVCONTAINER_FOLDER")
echo "Using devcontainer folder: $DEVCONTAINER_FOLDER"

## Get available Magento versions from compose folder
get_available_versions() {
    local versions=()
    while IFS= read -r -d '' dir; do
        local version=$(basename "$dir")
        if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            versions+=("$version")
        fi
    done < <(find "$DEVCONTAINER_FOLDER/compose" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null | sort -zV)
    echo "${versions[@]}"
}

## Prompt user to select a Magento version
select_magento_version() {
    local versions=($1)
    local default_version="${versions[-1]}"  # Latest version as default

    echo "Available Magento versions:"
    for i in "${!versions[@]}"; do
        local marker=""
        [ "${versions[$i]}" = "$default_version" ] && marker=" (latest)"
        echo "  $((i+1))) ${versions[$i]}$marker"
    done

    read -p "Select Magento version [${#versions[@]}]: " selection
    selection="${selection:-${#versions[@]}}"

    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#versions[@]} ]; then
        echo "${versions[$((selection-1))]}"
    else
        echo "Invalid selection." >&2
        return 1
    fi
}

AVAILABLE_VERSIONS=$(get_available_versions)

## Detect project Magento version
SELECTED_VERSION=""
if load_project_magento_version 2>/dev/null; then
    echo "Detected project Magento version: $PROJECT_MAGENTO_VERSION"

    # Check if we have a matching compose version
    if [ -d "$DEVCONTAINER_FOLDER/compose/$PROJECT_MAGENTO_VERSION" ]; then
        SELECTED_VERSION="$PROJECT_MAGENTO_VERSION"
        echo "Using matching devcontainer version: $SELECTED_VERSION"
    else
        echo "WARNING: No exact match for version $PROJECT_MAGENTO_VERSION"
        echo ""
        read -p "Select a compatible version manually? [Y/n]: " confirm
        if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
            SELECTED_VERSION=$(select_magento_version "$AVAILABLE_VERSIONS") || exit 1
        fi
    fi
else
    echo "No existing Magento project detected."
    echo ""
    SELECTED_VERSION=$(select_magento_version "$AVAILABLE_VERSIONS") || exit 1
fi

if [ -z "$SELECTED_VERSION" ]; then
    echo "Error: No Magento version selected."
    exit 1
fi

## Prompt for devcontainer name
read -p "Enter a name for your devcontainer (it should be unique per project) [$FOLDER_NAME]: " DEVCONTAINER_NAME
DEVCONTAINER_NAME="${DEVCONTAINER_NAME:-$FOLDER_NAME}"

## Copy over required docker-compose.yml.
cp "$DEVCONTAINER_FOLDER/docker-compose.overrides.yml.sample" .devcontainer/docker-compose.overrides.yml
echo "services: {}" > .devcontainer/docker-compose.yml

## Copy over devcontainer and set the name and version
cp "$DEVCONTAINER_FOLDER/devcontainer.json.sample" .devcontainer/devcontainer.json
sed -i "s/\"name\": \"My Project Magento\"/\"name\": \"$DEVCONTAINER_NAME\"/" .devcontainer/devcontainer.json
sed -i "s|$FOLDER_NAME/compose/[0-9]\+\.[0-9]\+\.[0-9]\+/|$FOLDER_NAME/compose/$SELECTED_VERSION/|g" .devcontainer/devcontainer.json

## Copy .env.sample and set the project name
cp "$DEVCONTAINER_FOLDER/.env.sample" .devcontainer/.env
sed -i "s/COMPOSE_PROJECT_NAME=\"magento2-devcontainer\"/COMPOSE_PROJECT_NAME=\"$DEVCONTAINER_NAME\"/" .devcontainer/.env

echo ""
echo "Devcontainer '$DEVCONTAINER_NAME' initialized successfully."
echo "  Magento version: $SELECTED_VERSION"
