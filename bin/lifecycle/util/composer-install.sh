#!/bin/bash

# Best-effort `composer install` on container create.
#
# Some Magento stacks resolve entirely from auth-free repositories
# (repo.mage-os.org / mirror.mage-os.org + packagist) and can install
# unattended. Others pull from license-gated repositories (repo.magento.com,
# Hyva) that require COMPOSER_AUTH or an auth.json — without credentials those
# installs 401 and would abort container creation. We auto-install only when
# every configured repository is on a positive auth-free allowlist.
#
# This script installs when it safely can and skips with guidance otherwise.
# It NEVER exits non-zero: a missing license or a failed install must not
# prevent you from getting a shell in the container to fix it by hand.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$BIN_DIR/lib/detect-devcontainer.sh"

# Repository hosts known to resolve without credentials. This is a positive
# allowlist: we auto-install only when EVERY repository the project configures
# is one of these (or packagist by default). Anything else — repo.magento.com,
# Hyva, a private vcs/path repo — is assumed to need credentials and is skipped
# unless creds are present. Extend as new auth-free mirrors come up.
SAFE_REPO_HOSTS_REGEX='^(packagist\.org|repo\.packagist\.org|repo\.mage-os\.org|mirror\.mage-os\.org)$'

notice() { echo "" >&2; echo "$@" >&2; echo "" >&2; }

# Locate the Magento root non-interactively. find_magento_root prompts via
# `read` when a monorepo exposes multiple roots; postCreateCommand has no tty,
# so feed it /dev/null — an ambiguous/empty result fails cleanly and we skip.
MAGENTO_ROOT="$(find_magento_root "." </dev/null 2>/dev/null)"
if [ -z "$MAGENTO_ROOT" ] || [ ! -f "$MAGENTO_ROOT/composer.json" ]; then
    notice "NOTICE: No Magento composer.json found — skipping composer install."
    exit 0
fi

# Already installed? Stay idempotent across rebuilds/reconnects. vendor/
# autoload.php is the marker the setup-install hook also keys off of.
if [ -f "$MAGENTO_ROOT/vendor/autoload.php" ]; then
    notice "NOTICE: $MAGENTO_ROOT/vendor already populated — skipping composer install."
    exit 0
fi

# Decide whether we're allowed to install. Credentials present (a Codespaces
# COMPOSER_AUTH secret or a committed/seeded auth.json) means we can install
# whatever the project needs. Otherwise we install only when the manifest's
# repositories are all on the auth-free allowlist.
have_credentials() {
    [ -n "$COMPOSER_AUTH" ] && return 0
    [ -f "$MAGENTO_ROOT/auth.json" ] && return 0
    [ -f "$HOME/.composer/auth.json" ] && return 0
    [ -f "$COMPOSER_HOME/auth.json" ] && return 0
    return 1
}

# True when every repository configured in composer.json is auth-free. jq is
# required to parse the manifest reliably; if it's missing we conservatively
# return false so the project is treated as needing credentials.
is_auth_free() {
    command -v jq >/dev/null 2>&1 || return 1

    # Emit one URL per configured repository. `.repositories[]?` iterates
    # whether repositories is an array or an object map (and is a no-op when
    # absent — no repositories means packagist only, which is auth-free).
    # select(type=="object") drops boolean entries like {"packagist.org": false}.
    local urls
    urls="$(jq -r '[.repositories[]? | select(type=="object") | .url // empty] | .[]' \
        "$MAGENTO_ROOT/composer.json" 2>/dev/null)" || return 1
    [ -z "$urls" ] && return 0

    local url host
    while IFS= read -r url; do
        [ -z "$url" ] && continue
        # Reduce the URL to its bare host: strip scheme, path, userinfo, port.
        host="${url#*://}"; host="${host%%/*}"; host="${host##*@}"; host="${host%%:*}"
        echo "$host" | grep -qiE "$SAFE_REPO_HOSTS_REGEX" || return 1
    done <<< "$urls"
    return 0
}

if ! have_credentials && ! is_auth_free; then
    notice "NOTICE: This project configures repositories that require credentials
        (e.g. repo.magento.com or Hyva) and no COMPOSER_AUTH was found —
        skipping automatic composer install.

        To install dependencies:
          1. Add a COMPOSER_AUTH Codespaces secret (or place an auth.json in the project root),
             then rebuild the container — or run the command below directly.
          2. (cd \"$MAGENTO_ROOT\" && composer install)

        See: https://getcomposer.org/doc/articles/authentication-for-private-packages.md"
    exit 0
fi

# Cleared to install.
echo "Running composer install in $MAGENTO_ROOT ..." >&2
if (cd "$MAGENTO_ROOT" && composer install --no-interaction --no-progress); then
    notice "composer install completed."
else
    notice "WARNING: composer install failed. Open a terminal and run it manually:
        (cd \"$MAGENTO_ROOT\" && composer install)"
fi
exit 0
