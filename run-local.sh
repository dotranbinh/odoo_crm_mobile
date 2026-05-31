#!/usr/bin/env bash
# Run Odoo CRM Mobile (Flutter Web) on Chrome with web security disabled for local Odoo CORS.
#
# Usage:
#   ./run-local.sh
#   ODOO_URL=http://localhost:8069 ODOO_DB=dev1 ./run-local.sh
#
# Requires: Flutter SDK, Chrome. Local Odoo: crm_odoo/crm_odoo_mobile (docker compose up).

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

ODOO_URL="${ODOO_URL:-http://localhost:8069}"
ODOO_DB="${ODOO_DB:-dev1}"
CHROME_USER_DATA_DIR="${CHROME_USER_DATA_DIR:-/tmp/chrome_cors_dev}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "error: flutter not found in PATH" >&2
  exit 1
fi

echo "Odoo CRM Mobile — Chrome (CORS disabled for dev)"
echo "  ODOO_URL=$ODOO_URL"
echo "  ODOO_DB=$ODOO_DB"
echo "  Chrome profile: $CHROME_USER_DATA_DIR"
echo ""

exec flutter run -d chrome \
  --dart-define=ODOO_URL="$ODOO_URL" \
  --dart-define=ODOO_DB="$ODOO_DB" \
  --web-browser-flag="--disable-web-security" \
  --web-browser-flag="--user-data-dir=$CHROME_USER_DATA_DIR" \
  "$@"
