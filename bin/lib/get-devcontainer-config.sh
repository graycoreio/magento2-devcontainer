#!/bin/bash

# get_devcontainer_config — locate the devcontainer.json and parse the
# compose key it points at into its distribution + version components.
# Used by bin/setup-install.sh to know which stack is currently wired.
#
# Depends on:
#   - find_devcontainer_json_path           (find-devcontainer-json-path.sh)
#   - detect_devcontainer_compose_key       (compose-keys.sh)
#
# Args:    none
# Sets (global, exported into the caller's shell):
#   DEVCONTAINER_JSON_PATH    path to the devcontainer.json that was found
#   DEVCONTAINER_COMPOSE_KEY  compose key parsed from dockerComposeFile,
#                             always "<distribution>/<version>"
#                             (e.g. "magento/2.4.9", "mage-os-minimal/3.0.0")
#   DEVCONTAINER_DISTRIBUTION distribution segment of the compose key
#                             ("magento" | "mage-os" | "mage-os-minimal")
#   DEVCONTAINER_VERSION      distribution-native version segment of the key
#                             (e.g. "2.4.9" for vanilla, "3.0.0" for mage-os)
#
# Note: this getter no longer exposes the *upstream Magento series* for
# mage-os stacks. Callers that need it should run
# `compose_key_to_magento_version "$DEVCONTAINER_COMPOSE_KEY"` explicitly.
#
# Stdout:  (nothing — output is via the globals above)
# Stderr:  progress messages on success; error messages on failure
# Returns: 0 on success; 1 if any step fails (later globals may be unset)
get_devcontainer_config() {
    DEVCONTAINER_JSON_PATH=$(find_devcontainer_json_path)

    if [ -z "$DEVCONTAINER_JSON_PATH" ] || [ ! -f "$DEVCONTAINER_JSON_PATH" ]; then
        echo "Error: No devcontainer.json found."
        echo "Please run bin/init.sh first to initialize your devcontainer."
        return 1
    fi

    echo "Using config: $DEVCONTAINER_JSON_PATH" >&2

    DEVCONTAINER_COMPOSE_KEY=$(detect_devcontainer_compose_key "$DEVCONTAINER_JSON_PATH")
    [ -z "$DEVCONTAINER_COMPOSE_KEY" ] && return 1

    DEVCONTAINER_DISTRIBUTION="${DEVCONTAINER_COMPOSE_KEY%%/*}"
    DEVCONTAINER_VERSION="${DEVCONTAINER_COMPOSE_KEY#*/}"

    echo "Detected devcontainer compose: $DEVCONTAINER_COMPOSE_KEY ($DEVCONTAINER_DISTRIBUTION $DEVCONTAINER_VERSION)" >&2
}
