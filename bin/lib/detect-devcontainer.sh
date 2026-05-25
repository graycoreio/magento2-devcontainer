#!/bin/bash

# Shared devcontainer detection utilities — aggregate entry point.
# Source this file from other scripts:
#   source "$(dirname "$0")/lib/detect-devcontainer.sh"
#
# Each concern lives in its own file under this directory:
#   - is-magento2-devcontainer-dir.sh    : is_magento2_devcontainer_dir
#                                          (signature-file predicate)
#   - find-magento2-devcontainer-dir.sh  : find_magento2_devcontainer_dir
#                                          (the support submodule)
#   - find-devcontainer-json-path.sh     : find_devcontainer_json_path
#                                          (the user's devcontainer.json)
#   - compose-keys.sh                    : compose key <-> distribution/version
#   - is-magento-root.sh                 : is_magento_root + package regex
#   - find-magento-root.sh               : find_magento_root (uses is_magento_root)
#   - get-devcontainer-config.sh         : get_devcontainer_config
#   - get-magento-version.sh             : get_magento_version (jq-based)
# Load order matters: each find-*.sh depends on the corresponding is-*.sh,
# and the getters depend on the helpers above them.

_DETECT_DEVCONTAINER_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$_DETECT_DEVCONTAINER_LIB_DIR/is-magento2-devcontainer-dir.sh"
source "$_DETECT_DEVCONTAINER_LIB_DIR/find-magento2-devcontainer-dir.sh"
source "$_DETECT_DEVCONTAINER_LIB_DIR/find-devcontainer-json-path.sh"
source "$_DETECT_DEVCONTAINER_LIB_DIR/compose-keys.sh"
source "$_DETECT_DEVCONTAINER_LIB_DIR/is-magento-root.sh"
source "$_DETECT_DEVCONTAINER_LIB_DIR/find-magento-root.sh"
source "$_DETECT_DEVCONTAINER_LIB_DIR/get-devcontainer-config.sh"
source "$_DETECT_DEVCONTAINER_LIB_DIR/get-magento-version.sh"
