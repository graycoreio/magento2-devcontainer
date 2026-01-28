#!/bin/bash

# Magento setup:install script generator
# Reads the devcontainer.json to determine the selected Magento version
# and generates the appropriate setup:install command

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/detect-devcontainer.sh"

load_devcontainer_config || exit 1

# Check for version mismatch with project
if load_project_magento_version; then
    if [ "$MAGENTO_VERSION" != "$PROJECT_MAGENTO_VERSION" ]; then
        echo "" >&2
        echo "WARNING: Version mismatch detected!" >&2
        echo "  Devcontainer configured for: $MAGENTO_VERSION" >&2
        echo "  Project composer.json uses:  $PROJECT_MAGENTO_VERSION" >&2
        echo "" >&2
        echo "Consider updating your devcontainer.json to use:" >&2
        echo "  compose/$PROJECT_MAGENTO_VERSION/docker-compose.yml" >&2
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

BASE_URL="${BASE_URL:-http://localhost/}"
BACKEND_FRONTNAME="${BACKEND_FRONTNAME:-admin}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin123}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"
ADMIN_FIRSTNAME="${ADMIN_FIRSTNAME:-Admin}"
ADMIN_LASTNAME="${ADMIN_LASTNAME:-User}"
LANGUAGE="${LANGUAGE:-en_US}"
CURRENCY="${CURRENCY:-USD}"
TIMEZONE="${TIMEZONE:-America/New_York}"

# Build the setup:install command
cat << 'EOF'
bin/magento setup:install \
EOF

cat << EOF
    --db-host="$DB_HOST" \\
    --db-name="$DB_NAME" \\
    --db-user="$DB_USER" \\
    --db-password="$DB_PASSWORD" \\
    --base-url="$BASE_URL" \\
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
    --amqp-host="$RABBITMQ_HOST" \\
    --amqp-port="$RABBITMQ_PORT" \\
    --amqp-user="$RABBITMQ_USER" \\
    --amqp-password="$RABBITMQ_PASSWORD" \\
    --cleanup-database
EOF

echo "" >&2
echo "# Magento Version: $MAGENTO_VERSION" >&2
echo "# To execute, copy the command above and run it in your workspace" >&2
echo "# Or pipe this script to bash: ./bin/setup-install.sh | bash" >&2