#!/bin/bash

# Cheap predicate for "is this the magento2-devcontainer support repo?".
# Used by find_magento2_devcontainer_dir to filter candidate directories.
#
# Identifies the repo authoritatively by reading package.json's `name` field.
# Beats heuristic file-presence checks: it's a single fact the repo states
# about itself, and a fork that changes the name has explicitly signaled
# it's not "the magento2-devcontainer".
#
# Depends on: jq (system binary; already required by get_magento_version)
#
# Args:    $1 = directory to inspect
# Stdout:  (nothing — predicate only)
# Returns: 0 if $dir/package.json declares name="magento2-devcontainer",
#          1 otherwise (including missing package.json, missing jq, or
#          malformed JSON — fails safely in all of these)
is_magento2_devcontainer_dir() {
    local dir="$1"
    [ -f "$dir/package.json" ] || return 1
    [ "$(jq -r '.name // empty' "$dir/package.json" 2>/dev/null)" = "magento2-devcontainer" ]
}
