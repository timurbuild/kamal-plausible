# Initialize .kamal/secrets with auto-generated cryptographic values
init:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f .kamal/secrets ]; then
        echo "Error: .kamal/secrets already exists. Remove it first to reinitialize."
        exit 1
    fi
    cp .kamal/secrets.example .kamal/secrets
    SECRET_KEY_BASE=$(openssl rand -base64 48)
    TOTP_VAULT_KEY=$(openssl rand -base64 32)
    POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d '/+=' | head -c 32)
    perl -i -pe "s/^SECRET_KEY_BASE=.*/SECRET_KEY_BASE=${SECRET_KEY_BASE}/" .kamal/secrets
    perl -i -pe "s/^TOTP_VAULT_KEY=.*/TOTP_VAULT_KEY=${TOTP_VAULT_KEY}/" .kamal/secrets
    perl -i -pe "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/" .kamal/secrets
    echo "Created .kamal/secrets with generated cryptographic values."
    echo ""
    echo "Now edit .kamal/secrets to set:"
    echo "  SERVER_IP                - your server's IP address"
    echo "  PLAUSIBLE_HOST           - domain name (e.g. analytics.example.com)"
    echo "  REGISTRY_USERNAME        - Docker registry username"
    echo "  KAMAL_REGISTRY_PASSWORD  - Docker registry password or access token"

# First-time server setup: provisions Docker, boots proxy + databases, deploys app
setup:
    kamal setup

# Deploy or update Plausible
deploy:
    kamal deploy

# Follow application logs
logs:
    kamal app logs -f

# Follow PostgreSQL logs
logs-db:
    kamal accessory logs db -f

# Follow ClickHouse logs
logs-events:
    kamal accessory logs events-db -f

# Reboot databases (e.g. after config changes)
reboot-db:
    kamal accessory reboot db

reboot-events:
    kamal accessory reboot events-db
