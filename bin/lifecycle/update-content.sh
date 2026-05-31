#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

"$SCRIPT_DIR/util/composer-install.sh"

exit 0
