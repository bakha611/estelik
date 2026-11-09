#!/usr/bin/env bash
# One-shot setup for the estelik server (Linux, or macOS for testing).
# Usage:  ./scripts/setup.sh [/path/to/photo/library]
set -euo pipefail

cd "$(dirname "$0")/../server"

command -v docker >/dev/null || { echo "Docker is not installed: https://docs.docker.com/engine/install/"; exit 1; }
docker compose version >/dev/null || { echo "Docker Compose v2 plugin missing."; exit 1; }

if [[ ! -f .env ]]; then
  cp .env.example .env
  if [[ -n "${1:-}" ]]; then
    sed -i.bak "s|^UPLOAD_LOCATION=.*|UPLOAD_LOCATION=${1}|" .env && rm -f .env.bak
  fi
  echo "Created server/.env"
fi

# Never run with the placeholder password (only safe to change before the DB is first created).
if grep -q '^DB_PASSWORD=change_me$' .env; then
  # `tr` dies of SIGPIPE when `head` closes the pipe; that is expected, not an error.
  pw=$( (LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom || true) | head -c 32 )
  sed -i.bak "s/^DB_PASSWORD=.*/DB_PASSWORD=${pw}/" .env && rm -f .env.bak
  echo "Generated a random DB password in server/.env"
fi

# shellcheck disable=SC1091
source .env
mkdir -p "$UPLOAD_LOCATION" "$DB_DATA_LOCATION"

echo "Free space where photos will live:"
df -h "$UPLOAD_LOCATION" | tail -1

docker compose pull
docker compose up -d

ip=$(hostname -I 2>/dev/null | awk '{print $1}' || true)
echo
echo "estelik is starting. Open http://${ip:-localhost}:2283 and create the admin account."
echo "First start can take a minute while the database initialises."
