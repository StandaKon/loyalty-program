#!/usr/bin/env bash
# Runs every B9 KPI control query from docs/implementation-blocks/B9-management-report/kpi-queries.md
# against the default org of this project (no target org is passed).
#
# Usage: scripts/bash/b9-kpi-queries.sh [PERIOD_START] [PERIOD_END] [CAMPAIGN_NAME] [BUDGET_YEAR]
#   defaults: October 2026 in Europe/Prague, "Natankuj plnou", 2026
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DOC="$ROOT/docs/implementation-blocks/B9-management-report/kpi-queries.md"

PERIOD_START="${1:-2026-10-01T00:00:00+02:00}"
PERIOD_END="${2:-2026-11-01T00:00:00+01:00}"
CAMPAIGN_NAME="${3:-Natankuj plnou}"
BUDGET_YEAR="${4:-2026}"

echo "Period: $PERIOD_START .. $PERIOD_END | Campaign: $CAMPAIGN_NAME | Budget year: $BUDGET_YEAR"

# Extract "### Kxx title" headings and the sql block that follows each of them.
awk '
  /^### K[0-9]+/ { title = substr($0, 5); next }
  /^```sql/ { insql = 1; next }
  /^```/ && insql { insql = 0; print title "\t" query; query = ""; next }
  insql { query = query $0 " " }
' "$DOC" | while IFS=$'\t' read -r title query; do
  query="${query//\{\{PERIOD_START\}\}/$PERIOD_START}"
  query="${query//\{\{PERIOD_END\}\}/$PERIOD_END}"
  query="${query//\{\{CAMPAIGN_NAME\}\}/$CAMPAIGN_NAME}"
  query="${query//\{\{BUDGET_YEAR\}\}/$BUDGET_YEAR}"
  echo
  echo "=== $title"
  sf data query --query "$query" 2>&1 | grep -vE "Warning: @salesforce/cli update|Querying Data" || true
done
