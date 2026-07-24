#!/usr/bin/env bash
# orient — runtime terrain brief for agents arriving in a Fastops repo.
#
# Command-plane tool: canonical home is Fastops5326/agent-orient (public,
# read-only to working repos). Working repos fetch and execute it; they never
# vendor a copy, so there is nothing in the working repo to append to or drift.
#
# Design laws:
#   1. GENERATED, NEVER WRITTEN — every line below is computed from live state
#      at the moment of contact. No stored prose. If a fact isn't queryable,
#      it doesn't appear here.
#   2. FAIL-SOFT — when a query is denied, print what the denial MEANS for the
#      agent, then keep going. A 403 is terrain too.
#   3. BUDGET — output stays under ~40 lines. Pointers, not explanations.
set -uo pipefail

say() { printf '%s\n' "$*"; }

NWO=$(gh repo view --json nameWithOwner --jq .nameWithOwner 2>/dev/null || true)
if [ -z "$NWO" ]; then
  say "ORIENT: not inside a GitHub repo checkout, or gh is unauthenticated."
  say "Onboard from live GitHub state: README, open issues, open PRs, latest CI."
  exit 0
fi
DEF=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null || echo "?")

say "=== ORIENT $NWO (default: $DEF) $(date -u +%Y-%m-%dT%H:%MZ) ==="

# --- GATES: what must be green before anything merges -----------------------
CHECKS=$(gh api "repos/$NWO/rules/branches/$DEF" \
  --jq '[.[] | select(.type=="required_status_checks") | .parameters.required_status_checks[].context] | unique | join(", ")' 2>/dev/null || true)
if [ -n "$CHECKS" ]; then
  say "GATES    required to merge into $DEF: $CHECKS"
  case "$CHECKS" in *plan-gate-status*)
    say "         plan gate arms only via the 'plan:review' label; unlabeled PRs pass it automatically." ;;
  esac
else
  say "GATES    none readable — assume PRs are reviewed before merge."
fi

# --- CI: what runs, and whether it last worked -------------------------------
# The workflows API includes stale registrations left over from deleted
# branches; the contents API on the default branch is the truth. (Defect
# found by flight record #3: a ghost workflow misled the arriving agent.)
BRANCH_WF=$(gh api "repos/$NWO/contents/.github/workflows?ref=$DEF" --jq '.[].name' 2>/dev/null || true)
WFS=""
if [ -n "$BRANCH_WF" ]; then
  ALL=$(gh api "repos/$NWO/actions/workflows" \
    --jq '.workflows[] | select(.state=="active") | (.path | sub(".*/";"")) + "|" + .name' 2>/dev/null || true)
  COUNT=0
  while IFS='|' read -r file name; do
    [ -z "$file" ] && continue
    if [ "$COUNT" -lt 5 ] && printf '%s\n' "$BRANCH_WF" | grep -qxF "$file"; then
      WFS="${WFS}           - $name [$file]"$'\n'
      COUNT=$((COUNT+1))
    fi
  done <<< "$ALL"
fi
if [ -n "$WFS" ]; then
  say "CI       workflows on $DEF:"
  printf '%s' "$WFS"
  LAST=$(gh api "repos/$NWO/actions/runs?per_page=1" \
    --jq '.workflow_runs[0] | .name + ": " + (.conclusion // .status)' 2>/dev/null || true)
  [ -n "$LAST" ] && say "         latest run — $LAST"
else
  say "CI       no workflows on $DEF — your change will not be checked automatically; verify it yourself."
fi

# --- ENV: is setup declared, or must you discover it? ------------------------
if [ -f .cursor/environment.json ]; then
  say "ENV      .cursor/environment.json:"
  head -c 600 .cursor/environment.json | sed 's/^/           /'
  say ""
else
  say "ENV      no .cursor/environment.json — setup is undeclared; expect to discover install/run yourself."
fi

# --- WORK: open issues and PRs (the live queue) -------------------------------
ISSUES=$(gh api "repos/$NWO/issues?state=open&per_page=5" \
  --jq '[.[] | select(has("pull_request") | not)][] | "#" + (.number|tostring) + " " + .title' 2>/dev/null)
if [ -z "$ISSUES" ]; then
  ISSUES_ERR=$(gh api "repos/$NWO/issues?state=open&per_page=1" 2>&1 >/dev/null || true)
  case "$ISSUES_ERR" in
    *403*|*404*) say "WORK     issues UNREADABLE from this token — treat your prompt as the complete work order." ;;
    *)           say "WORK     no open issues." ;;
  esac
else
  say "WORK     open issues:"
  while IFS= read -r i; do say "           $i"; done <<< "$ISSUES"
fi
PRS=$(gh pr list --limit 5 --json number,title,mergeStateStatus \
  --jq '.[] | "#" + (.number|tostring) + " " + .title + " [" + .mergeStateStatus + "]"' 2>/dev/null || true)
if [ -n "$PRS" ]; then
  say "         open PRs (avoid duplicating; rebase if touching the same files):"
  while IFS= read -r p; do say "           $p"; done <<< "$PRS"
fi

# --- CONTEXT: where the text lives, if you need it ---------------------------
CTX=""
[ -f README.md ] && CTX="README.md"
[ -d docs ] && CTX="$CTX docs/"
[ -f .github/pull_request_template.md ] || [ -f .github/PULL_REQUEST_TEMPLATE.md ] && CTX="$CTX PR-template"
if [ -n "$CTX" ]; then
  say "CONTEXT  $CTX  (reference only — live state above outranks all prose)"
else
  say "CONTEXT  no README/docs — the code and the queue above are all there is."
fi

say "=== END ORIENT — everything above was computed just now; nothing is maintained by hand ==="
