#!/bin/bash

# get_magento_version — find the Magento root inside a workspace, identify
# which composer product package is installed, and read the distribution-
# native version straight from the composer manifest.
#
# Modeled on the github-actions-magento2 reference implementation so the
# detection logic stays in sync across our tooling:
# https://github.com/graycoreio/github-actions-magento2/blob/main/get-magento-version/get-magento-version.sh
#
# Depends on:
#   - jq                                    (system binary)
#   - find_magento_root                     (find-magento-root.sh)
#
# Args:    $1 = search root (defaults to ".")
# Sets (global, exported into the caller's shell):
#   MAGENTO_ROOT          path to the installed Magento root (may be ".")
#   PROJECT_PACKAGE       composer package that identified the install,
#                         e.g. "mage-os/product-minimal-edition"
#   PROJECT_DISTRIBUTION  one of: "magento" | "mage-os" | "mage-os-minimal"
#   PROJECT_VERSION       distribution-native version straight from composer,
#                         e.g. "2.4.9" for vanilla, "3.0.0" for mage-os
# Stdout:  (nothing — output is via the globals above)
# Stderr:  progress messages on success; error messages on failure
# Returns: 0 on success; 1 if jq is unavailable, no Magento root is found,
#          or no recognized product package is in the composer manifest
get_magento_version() {
    local search_root="${1:-.}"

    if ! command -v jq >/dev/null 2>&1; then
        echo "Error: jq is required for project detection but is not installed." >&2
        return 1
    fi

    MAGENTO_ROOT=$(find_magento_root "$search_root")
    if [ -z "$MAGENTO_ROOT" ]; then
        echo "Could not find Magento installation" >&2
        return 1
    fi

    echo "Found Magento root: $MAGENTO_ROOT" >&2

    # Same package-name pattern the github-actions-magento2 detector uses —
    # keep them in lockstep so both tools agree on what counts as a Magento
    # install. mage-os has community/minimal variants; vanilla Magento has
    # community/enterprise.
    local pattern='magento/product-(community|enterprise)-edition|mage-os/product-(community|minimal)-edition'

    # composer.lock holds the *resolved* version, which is what we want.
    # Fall back to composer.json (the require constraint) only if lock is
    # missing — e.g. a freshly cloned project not yet installed.
    local result=""
    if [ -f "$MAGENTO_ROOT/composer.lock" ]; then
        result=$(jq -r --arg p "$pattern" \
            '.packages[]? | select(.name | test($p)) | "\(.name) \(.version)"' \
            "$MAGENTO_ROOT/composer.lock" 2>/dev/null | head -1)
    fi
    if [ -z "$result" ] && [ -f "$MAGENTO_ROOT/composer.json" ]; then
        result=$(jq -r --arg p "$pattern" \
            '.require // {} | to_entries[] | select(.key | test($p)) | "\(.key) \(.value)"' \
            "$MAGENTO_ROOT/composer.json" 2>/dev/null | head -1)
    fi

    if [ -z "$result" ]; then
        echo "Could not detect a Magento/mage-os product package in composer manifest" >&2
        return 1
    fi

    PROJECT_PACKAGE=$(awk '{print $1}' <<<"$result")
    # Strip leading "v" so composer.json constraints like "v2.4.9" land as "2.4.9".
    PROJECT_VERSION=$(awk '{print $2}' <<<"$result" | sed 's/^v//')

    case "$PROJECT_PACKAGE" in
        magento/product-community-edition|magento/product-enterprise-edition)
            PROJECT_DISTRIBUTION="magento" ;;
        mage-os/product-minimal-edition)
            PROJECT_DISTRIBUTION="mage-os-minimal" ;;
        mage-os/product-community-edition)
            PROJECT_DISTRIBUTION="mage-os" ;;
        *)
            echo "Could not classify distribution from package $PROJECT_PACKAGE" >&2
            return 1 ;;
    esac

    echo "Detected project: $PROJECT_DISTRIBUTION $PROJECT_VERSION ($PROJECT_PACKAGE)" >&2
}
