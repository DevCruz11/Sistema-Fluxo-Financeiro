#!/usr/bin/env bash
# Validação pós-recuperação do banco DMF-Render.
# Uso:
#   BASE=https://dmf-render.onrender.com \
#   ADMIN_USER=admin ADMIN_PASS='SuaSenhaForte!' \
#   bash scripts/validate-recovery.sh
set -euo pipefail

BASE="${BASE:-https://dmf-render.onrender.com}"
ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASS="${ADMIN_PASS:-}"

echo "== 1. Health =="
curl -s -m 20 "$BASE/api/health" \
  | (jq '{boot: .boot.ready, db_ready, roles, host: .db.host_hint}' 2>/dev/null || cat)

echo
echo "== 2. Login =="
if [ -z "$ADMIN_PASS" ]; then
  echo "Defina ADMIN_PASS para testar o login. Pulando."
else
  curl -s -m 20 -o /dev/null -w "HTTP %{http_code}\n" \
    -X POST "$BASE/api/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$ADMIN_USER\",\"password\":\"$ADMIN_PASS\"}"
fi

echo
echo "Esperado: db_ready=true, roles=<número>, login HTTP 200."
