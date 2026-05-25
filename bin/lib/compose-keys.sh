#!/bin/bash

# Compose-key mapping: translates between distribution names, versions, and
# the compose/<key>/ directory the devcontainer points at.
#
# The "compose key" is the path between `compose/` and `/docker-compose.yml`
# in devcontainer.json's dockerComposeFile entry. Always two segments:
#   - Vanilla Magento → "magento/<magento-version>"      (e.g. magento/2.4.9)
#   - mage-os        → "mage-os/<mage-os-version>"       (e.g. mage-os/3.0.0)
#   - mage-os minimal → "mage-os-minimal/<mage-os-version>"
#
# New mage-os release lines are added in `compose_key_to_magento_version`.

# Map a compose key to the underlying Magento version. For vanilla Magento
# this is just the version after `magento/`; for mage-os it's the upstream
# Magento series the mage-os release tracks.
#
# Args:    $1 = compose key (e.g. "magento/2.4.9", "mage-os/3.0.0")
# Stdout:  Magento version string (e.g. "2.4.9")
# Returns: 0 on success, 1 if the key isn't recognized
compose_key_to_magento_version() {
    local key="$1"
    case "$key" in
        magento/*) echo "${key#magento/}" ;;
        # mage-os releases → upstream Magento each tracks
        mage-os/3.0.0|mage-os-minimal/3.0.0) echo "2.4.9" ;;
        *) return 1 ;;
    esac
}

# Detect the compose key the devcontainer is configured for by parsing the
# dockerComposeFile path. Every supported key is two segments separated by
# a slash, so a single alternation handles all distributions.
#
# Args:    $1 = path to devcontainer.json
# Stdout:  compose key (e.g. "magento/2.4.9", "mage-os-minimal/3.0.0")
# Stderr:  diagnostic listing the accepted path shapes when no match found
# Returns: 0 on success, 1 if no key could be extracted
detect_devcontainer_compose_key() {
    local config_file="$1"

    local key
    key=$(grep -oP '[^"/]+/compose/\K(magento|mage-os-minimal|mage-os)/[0-9]+\.[0-9]+\.[0-9]+(?=/docker-compose\.yml)' "$config_file" | head -1)

    if [ -z "$key" ]; then
        echo "Could not auto-detect compose key from $config_file" >&2
        echo "Expected a dockerComposeFile path like:" >&2
        echo "  <folder>/compose/magento/2.4.9/docker-compose.yml" >&2
        echo "  <folder>/compose/mage-os/3.0.0/docker-compose.yml" >&2
        echo "  <folder>/compose/mage-os-minimal/3.0.0/docker-compose.yml" >&2
        return 1
    fi

    echo "$key"
}

# Detect the devcontainer's configured Magento version from devcontainer.json.
# Wraps compose-key detection + key→version mapping so callers that only need
# the version don't have to do both steps.
#
# Args:    $1 = path to devcontainer.json
# Stdout:  Magento version (e.g. "2.4.9")
# Stderr:  inherited from detect_devcontainer_compose_key on failure
# Returns: 0 on success, 1 if either detection step fails
detect_devcontainer_magento_version() {
    local config_file="$1"
    local key
    key=$(detect_devcontainer_compose_key "$config_file") || return 1
    compose_key_to_magento_version "$key"
}
