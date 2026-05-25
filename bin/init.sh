#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/detect-devcontainer.sh"

## Find the devcontainer folder
if ! DEVCONTAINER_FOLDER=$(find_magento2_devcontainer_dir); then
    echo "Error: Could not find magento2-devcontainer folder in .devcontainer/"
    echo "Ensure you have cloned the magento2-devcontainer repo as a submodule."
    exit 1
fi

FOLDER_NAME=$(basename "$DEVCONTAINER_FOLDER")
TARGET_DIR=$(dirname "$DEVCONTAINER_FOLDER")
echo "Using devcontainer folder: $DEVCONTAINER_FOLDER"
echo "Target directory: $TARGET_DIR"

## Available Magento versions (version:label)
## Set label to "default" for the default version, "beta" for beta versions
VERSIONS=(
    "2.4.6:"
    "2.4.7:"
    "2.4.8"
    "2.4.9:default"
)

## Prompt user to select a Magento version
select_magento_version() {
    local default_index=0

    echo "Available Magento versions:" >&2
    for i in "${!VERSIONS[@]}"; do
        local entry="${VERSIONS[$i]}"
        local version="${entry%%:*}"
        local label="${entry#*:}"
        local marker=""

        if [ "$label" = "default" ]; then
            marker=" (latest)"
            default_index=$((i + 1))
        elif [ "$label" = "beta" ]; then
            marker=" (beta)"
        fi

        echo "  $((i+1))) ${version}$marker" >&2
    done

    read -p "Select Magento version [$default_index]: " selection
    selection="${selection:-$default_index}"

    if [[ "$selection" =~ ^[0-9]+$ ]] && [ "$selection" -ge 1 ] && [ "$selection" -le ${#VERSIONS[@]} ]; then
        local entry="${VERSIONS[$((selection-1))]}"
        echo "${entry%%:*}"
    else
        echo "Invalid selection." >&2
        return 1
    fi
}

## Pick a compose key — the <distribution>/<version> path under compose/
## that the devcontainer will be wired to. Auto-detected from the project's
## composer manifest when present; otherwise prompts for a Magento version.
if get_magento_version 2>/dev/null; then
    SELECTED_KEY="$PROJECT_DISTRIBUTION/$PROJECT_VERSION"
elif MANUAL_VERSION=$(select_magento_version); then
    SELECTED_KEY="magento/$MANUAL_VERSION"
else
    exit 1
fi

## First fallback: strip a `-pN` patch suffix and retry. Magento ships
## patch releases like 2.4.6-p15 that share the same docker stack as 2.4.6,
## so we don't need a separate compose dir per patch.
if [ ! -d "$DEVCONTAINER_FOLDER/compose/$SELECTED_KEY" ]; then
    BASE_KEY="${SELECTED_KEY%-p[0-9]*}"
    if [ "$BASE_KEY" != "$SELECTED_KEY" ] && [ -d "$DEVCONTAINER_FOLDER/compose/$BASE_KEY" ]; then
        echo "No exact compose stack for $SELECTED_KEY — using compatible $BASE_KEY"
        SELECTED_KEY="$BASE_KEY"
    fi
fi

## Second fallback: if still no match, offer to substitute a Magento version
## manually (vanilla only — mage-os errors out since there's no menu for it).
if [ ! -d "$DEVCONTAINER_FOLDER/compose/$SELECTED_KEY" ]; then
    case "$SELECTED_KEY" in
        magento/*)
            echo "WARNING: No compose stack for $SELECTED_KEY"
            read -p "Select a compatible Magento version manually? [Y/n]: " confirm
            if [[ "$confirm" =~ ^[Nn]$ ]]; then
                echo "Aborted." >&2
                exit 1
            fi
            MANUAL_VERSION=$(select_magento_version) || exit 1
            SELECTED_KEY="magento/$MANUAL_VERSION"
            ;;
        *)
            echo "Error: No compose stack for $SELECTED_KEY." >&2
            exit 1
            ;;
    esac
fi

echo "Using compose stack: $SELECTED_KEY"

## Prompt for devcontainer name
read -p "Enter a name for your devcontainer (it should be unique per project) [$FOLDER_NAME]: " DEVCONTAINER_NAME
DEVCONTAINER_NAME="${DEVCONTAINER_NAME:-$FOLDER_NAME}"

## Copy over required docker-compose files
cp "$DEVCONTAINER_FOLDER/docker-compose.shared.yml.sample" "$TARGET_DIR/docker-compose.shared.yml"
cp "$DEVCONTAINER_FOLDER/docker-compose.local.yml.sample" "$TARGET_DIR/docker-compose.local.yml"
echo "services: {}" > "$TARGET_DIR/docker-compose.yml"

## Copy over devcontainer and set the name and compose key.
## Every compose key is <distribution>/<version> so a single alternation
## covers magento, mage-os, and mage-os-minimal. Uses `#` as the s-delimiter
## so the `/` inside compose keys doesn't terminate the substitution early.
cp "$DEVCONTAINER_FOLDER/devcontainer.json.sample" "$TARGET_DIR/devcontainer.json"
sed -i "s/\"name\": \"My Project Magento\"/\"name\": \"$DEVCONTAINER_NAME\"/" "$TARGET_DIR/devcontainer.json"
sed -i -E "s#$FOLDER_NAME/compose/(magento|mage-os-minimal|mage-os)/[0-9]+\.[0-9]+\.[0-9]+/#$FOLDER_NAME/compose/$SELECTED_KEY/#g" "$TARGET_DIR/devcontainer.json"

## Copy .env.sample and set the project name
cp "$DEVCONTAINER_FOLDER/.env.sample" "$TARGET_DIR/.env"
sed -i "s/COMPOSE_PROJECT_NAME=\"magento2-devcontainer\"/COMPOSE_PROJECT_NAME=\"$DEVCONTAINER_NAME\"/" "$TARGET_DIR/.env"

echo ""
echo "Devcontainer '$DEVCONTAINER_NAME' initialized successfully."
echo "  Compose stack: $SELECTED_KEY"
