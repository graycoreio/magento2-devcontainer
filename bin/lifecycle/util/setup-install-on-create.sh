#!/bin/bash

# Run Magento's setup:install on container create — but ONLY once the project's
# dependencies are actually present, i.e. vendor/autoload.php exists.
#
# Composes the install command via bin/setup-install.sh (which derives all the
# DB / search / cache flags and no-ops if app/etc/env.php already exists) and
# pipes it to bash. Like its companion, this NEVER exits non-zero: a failed
# install must not abort container creation.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$BIN_DIR/lib/detect-devcontainer.sh"

notice() { echo "" >&2; echo "$@" >&2; echo "" >&2; }

# Resolve the Magento root non-interactively (see composer-install.sh for the
# /dev/null rationale around the monorepo selection prompt).
MAGENTO_ROOT="$(find_magento_root "." </dev/null 2>/dev/null)"
if [ -z "$MAGENTO_ROOT" ] || [ ! -f "$MAGENTO_ROOT/vendor/autoload.php" ]; then
    notice "NOTICE: vendor/autoload.php not present — composer install hasn't run, skipping setup:install."
    exit 0
fi

echo "Running setup:install ..." >&2
# Pass the resolved root so both hooks target the same tree. setup-install.sh
# no-ops when app/etc/env.php already exists, so this is safe to re-enter.
# </dev/null keeps it non-interactive: the stack-mismatch prompt reads from
# /dev/tty, so with no tty it falls through rather than blocking the hook.
if MAGENTO_ROOT="$MAGENTO_ROOT" "$BIN_DIR/setup-install.sh" </dev/null | bash; then
    notice "setup:install completed."
else
    notice "WARNING: setup:install failed. Open a terminal and run it manually:
        $SCRIPT_DIR/setup-install.sh | bash"
fi
exit 0
