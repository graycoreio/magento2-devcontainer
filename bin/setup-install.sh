#!/bin/bash

# Magento setup:install script generator
# Reads the devcontainer.json to determine the selected Magento version
# and generates the appropriate setup:install command

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/detect-devcontainer.sh"

get_devcontainer_config || exit 1

# mage-os minimal omits rabbitmq from its compose stack. Setup:install will
# hang crash on a non-existent flags if we pass --amqp-* flags. 
# Drive both off the compose key the devcontainer is configured for.
USE_RABBITMQ=1
if [[ "$DEVCONTAINER_COMPOSE_KEY" == mage-os-minimal/* ]]; then
    USE_RABBITMQ=0
fi

# Check for distribution/version mismatch with the installed project.
# Comparing compose keys (not just version strings) catches the case where
# the devcontainer is on a vanilla stack but composer.json has mage-os, or
# where the major version diverges — both would have been masked by the
# previous "compare upstream Magento version" approach.
if get_magento_version; then
    PROJECT_COMPOSE_KEY="$PROJECT_DISTRIBUTION/$PROJECT_VERSION"
    if [ "$DEVCONTAINER_COMPOSE_KEY" != "$PROJECT_COMPOSE_KEY" ]; then
        echo "" >&2
        echo "WARNING: Stack mismatch detected!" >&2
        echo "  Devcontainer configured for: $DEVCONTAINER_COMPOSE_KEY" >&2
        echo "  Project composer.json uses:  $PROJECT_COMPOSE_KEY ($PROJECT_PACKAGE)" >&2
        echo "" >&2
        echo "Consider re-running bin/init.sh to align the compose stack." >&2
        echo "" >&2
        read -p "Continue anyway? [y/N]: " confirm </dev/tty
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "Aborted." >&2
            exit 1
        fi
        echo "" >&2
    fi
fi

# Default configuration (matches docker-compose service settings)
DB_HOST="${DB_HOST:-db}"
DB_NAME="${DB_NAME:-magento}"
DB_USER="${DB_USER:-magento}"
DB_PASSWORD="${DB_PASSWORD:-magento}"

OPENSEARCH_HOST="${OPENSEARCH_HOST:-opensearch}"
OPENSEARCH_PORT="${OPENSEARCH_PORT:-9200}"

RABBITMQ_HOST="${RABBITMQ_HOST:-rabbitmq}"
RABBITMQ_PORT="${RABBITMQ_PORT:-5672}"
RABBITMQ_USER="${RABBITMQ_USER:-magento}"
RABBITMQ_PASSWORD="${RABBITMQ_PASSWORD:-magento}"

REDIS_HOST="${REDIS_HOST:-redis}"
REDIS_PORT="${REDIS_PORT:-6379}"

BASE_URL="${BASE_URL:-http://localhost:8000/}"
USE_SECURE="${USE_SECURE:-0}"
BASE_URL_SECURE="${BASE_URL_SECURE:-}"

# GitHub Codespaces: forwarded URL is always HTTPS and follows the pattern
# https://<codespace-name>-<port>.<forwarding-domain>/
if [ -n "$CODESPACE_NAME" ] && [ -n "$GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN" ]; then
    BASE_URL="${BASE_URL_OVERRIDE:-https://${CODESPACE_NAME}-8000.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}/}"
    BASE_URL_SECURE="$BASE_URL"
    USE_SECURE=1
fi

BACKEND_FRONTNAME="${BACKEND_FRONTNAME:-admin}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin123}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"
ADMIN_FIRSTNAME="${ADMIN_FIRSTNAME:-Admin}"
ADMIN_LASTNAME="${ADMIN_LASTNAME:-User}"
LANGUAGE="${LANGUAGE:-en_US}"
CURRENCY="${CURRENCY:-USD}"
TIMEZONE="${TIMEZONE:-America/New_York}"

# Resolve the Magento root for the file ops and the printed install command.
# `get_magento_version` sets MAGENTO_ROOT via find_magento_root, which
# walks subdirs and supports monorepo layouts (e.g. magento/ alongside a
# storefront workspace). Honor an explicit env override; fall back to cwd when
# the project's Magento version couldn't be detected (e.g. pre-install).
MAGENTO_ROOT="${MAGENTO_ROOT:-.}"

# Wait for sibling docker services to accept TCP connections.
# `setup:install` has no retry of its own and aborts on the first refused
# connection, which is a problem when this script is wired as
# devcontainer.json's postCreateCommand and runs while db / rabbitmq /
# opensearch are still booting. Caps the wait at
# WAIT_FOR_SERVICES_TIMEOUT_S (default 120s); if services never come up,
# falls through and lets setup:install produce the real error.
tcp_check() {
    timeout 1 bash -c ">/dev/tcp/$1/$2" 2>/dev/null
}

wait_for_services() {
    local wait_timeout="${WAIT_FOR_SERVICES_TIMEOUT_S:-60}"
    local elapsed=0 sleep_for=2
    while [ "$elapsed" -lt "$wait_timeout" ]; do
        local pending=()
        tcp_check "$DB_HOST" 3306                       || pending+=("db ($DB_HOST:3306)")
        if [ "$USE_RABBITMQ" = "1" ]; then
            tcp_check "$RABBITMQ_HOST" "$RABBITMQ_PORT" || pending+=("rabbitmq ($RABBITMQ_HOST:$RABBITMQ_PORT)")
        fi
        tcp_check "$OPENSEARCH_HOST" "$OPENSEARCH_PORT" || pending+=("opensearch ($OPENSEARCH_HOST:$OPENSEARCH_PORT)")
        if [ ${#pending[@]} -eq 0 ]; then
            echo "# All services reachable after ${elapsed}s." >&2
            return 0
        fi
        for svc in "${pending[@]}"; do
            echo "# Waiting for $svc, trying again in ${sleep_for}s..." >&2
        done
        sleep "$sleep_for"
        elapsed=$((elapsed + sleep_for))
    done
    echo "# Services not reachable after ${wait_timeout}s — proceeding anyway." >&2
    return 1
}

wait_for_services || true

# Setting system permissions
# Restrict to files owned by the current user; files owned by other users
# (e.g. www-data-generated artifacts) already have the correct group-writable
# permissions and can't be chmod'd without sudo.
find "$MAGENTO_ROOT/var" "$MAGENTO_ROOT/generated" "$MAGENTO_ROOT/vendor" "$MAGENTO_ROOT/pub/static" "$MAGENTO_ROOT/pub/media" "$MAGENTO_ROOT/app/etc" -type f -user "$(id -u)" -exec chmod g+w {} +
find "$MAGENTO_ROOT/var" "$MAGENTO_ROOT/generated" "$MAGENTO_ROOT/vendor" "$MAGENTO_ROOT/pub/static" "$MAGENTO_ROOT/pub/media" "$MAGENTO_ROOT/app/etc" -type d -user "$(id -u)" -exec chmod g+ws {} +
chmod u+x "$MAGENTO_ROOT/bin/magento"

# Build the setup:install command. Prepend a `cd` for monorepo layouts so the
# printed command works regardless of the caller's cwd when piped to bash.
# When MAGENTO_ROOT is cwd ("."), emit nothing — preserves legacy output.
if [ "$MAGENTO_ROOT" != "." ]; then
    echo "cd \"$MAGENTO_ROOT\" && \\"
fi
cat << 'EOF'
bin/magento setup:install \
EOF

cat << EOF
    --db-host="$DB_HOST" \\
    --db-name="$DB_NAME" \\
    --db-user="$DB_USER" \\
    --db-password="$DB_PASSWORD" \\
    --base-url="$BASE_URL" \\
EOF

# Magento validates --base-url-secure as https://, so only emit the secure
# flags when we actually have an HTTPS endpoint (e.g. Codespaces forwarding).
if [ "$USE_SECURE" = "1" ] && [ -n "$BASE_URL_SECURE" ]; then
    cat << EOF
    --base-url-secure="$BASE_URL_SECURE" \\
    --use-secure=1 \\
    --use-secure-admin=1 \\
EOF
fi

cat << EOF
    --backend-frontname="$BACKEND_FRONTNAME" \\
    --admin-user="$ADMIN_USER" \\
    --admin-password="$ADMIN_PASSWORD" \\
    --admin-email="$ADMIN_EMAIL" \\
    --admin-firstname="$ADMIN_FIRSTNAME" \\
    --admin-lastname="$ADMIN_LASTNAME" \\
    --language="$LANGUAGE" \\
    --currency="$CURRENCY" \\
    --timezone="$TIMEZONE" \\
    --use-rewrites=1 \\
    --search-engine=opensearch \\
    --opensearch-host="$OPENSEARCH_HOST" \\
    --opensearch-port="$OPENSEARCH_PORT" \\
    --session-save=redis \\
    --session-save-redis-host="$REDIS_HOST" \\
    --session-save-redis-port="$REDIS_PORT" \\
    --session-save-redis-db=0 \\
    --cache-backend=redis \\
    --cache-backend-redis-server="$REDIS_HOST" \\
    --cache-backend-redis-port="$REDIS_PORT" \\
    --cache-backend-redis-db=1 \\
    --page-cache=redis \\
    --page-cache-redis-server="$REDIS_HOST" \\
    --page-cache-redis-port="$REDIS_PORT" \\
    --page-cache-redis-db=2 \\
EOF

# mage-os minimal ships without rabbitmq; passing --amqp-* would cause
# setup:install to fail on connection. Emit the AMQP flags only when the
# stack actually has rabbitmq.
if [ "$USE_RABBITMQ" = "1" ]; then
    cat << EOF
    --amqp-host="$RABBITMQ_HOST" \\
    --amqp-port="$RABBITMQ_PORT" \\
    --amqp-user="$RABBITMQ_USER" \\
    --amqp-password="$RABBITMQ_PASSWORD" \\
EOF
fi

cat << 'EOF'
    --cleanup-database
EOF

echo "" >&2
echo "# Stack: $DEVCONTAINER_COMPOSE_KEY (upstream Magento $(compose_key_to_magento_version "$DEVCONTAINER_COMPOSE_KEY"))" >&2
echo "# To execute, copy the command above and run it in your workspace" >&2
echo "# Or pipe this script to bash: ./bin/setup-install.sh | bash" >&2