#!/bin/bash

# Cheap predicate for "is this directory a Magento installation?". Used by
# find_magento_root to walk candidate directories without paying the jq
# startup cost on every file. Detailed package/version detection lives in
# get-magento-version.sh.

# Product packages we treat as marking a Magento root. Mirrors the regex
# used by get_magento_version and the upstream github-actions-magento2
# detector: magento has community/enterprise; mage-os has community/minimal.
MAGENTO_PRODUCT_PACKAGES_REGEX='(magento/product-(community|enterprise)-edition|mage-os/product-(community|minimal)-edition)'

# Check whether a directory is a Magento root by looking for a composer
# manifest that references one of the recognized product packages.
#
# Args:    $1 = directory to inspect
# Stdout:  (nothing — predicate only)
# Returns: 0 if the directory looks like a Magento root, 1 otherwise
is_magento_root() {
    local dir="$1"

    # Must have composer.json
    [ -f "$dir/composer.json" ] || return 1

    if [ -f "$dir/composer.lock" ]; then
        grep -qE "\"$MAGENTO_PRODUCT_PACKAGES_REGEX\"" "$dir/composer.lock" && return 0
    fi

    grep -qE "\"$MAGENTO_PRODUCT_PACKAGES_REGEX\"" "$dir/composer.json" && return 0

    return 1
}
