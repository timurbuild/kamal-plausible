# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Infrastructure-as-code repo for deploying Plausible Analytics Community Edition via Kamal 2. This is NOT application code -- it's deployment configuration. There is no build step, no tests, no linting.

## Commands

```bash
just init      # Generate .kamal/secrets from template with cryptographic values
just setup     # First-time server provisioning + deploy (kamal setup)
just deploy    # Subsequent deploys (kamal deploy)
just logs      # Follow app logs
```

## How It Works

`config/deploy.yml` is an ERB-templated Kamal 2 config. All site-specific values come from `.kamal/secrets` (gitignored) via `<%= ENV['...'] %>`. Optional features (SMTP, Google, MaxMind) use ERB conditionals -- uncommenting a variable in `.kamal/secrets` automatically includes it in the deploy config. Users should never need to edit `deploy.yml`.

The `Dockerfile` is a one-liner `FROM` that re-tags the official Plausible CE image for Kamal's build-push-deploy workflow.

## Key Design Decisions

- **Databases are Kamal accessories** (not the primary service). Container names follow `<service>-<accessory>` pattern: `plausible-db`, `plausible-events-db`. These names are used in `DATABASE_URL` and `CLICKHOUSE_DATABASE_URL`.
- **No database ports published to host** -- only reachable via Docker's internal `kamal` network.
- **`forward_headers` is intentionally commented out** (defaults to `false` with `ssl: true`). Only enable if a trusted CDN/load balancer sits in front of kamal-proxy, otherwise clients can spoof X-Forwarded-For and poison analytics data.
- **ClickHouse XML configs in `clickhouse/`** are mounted into the container via Kamal's `files:` directive. They match Plausible's official docker-compose recommendations.
- **Postgres 16** is pinned because that's what Plausible officially tests against.
