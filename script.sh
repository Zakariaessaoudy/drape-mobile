#!/usr/bin/env bash
# ============================================================
#  restructure-drape.sh
#  Renames folders, removes build artifacts, scaffolds missing
#  directories, updates .gitignore, and commits everything.
#
#  Usage:  bash restructure-drape.sh
#  Run from anywhere inside the drape repo.
# ============================================================
set -euo pipefail

# ── colours ─────────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YLW='\033[1;33m'
BLU='\033[0;34m'; CYN='\033[0;36m'; RST='\033[0m'
info()    { echo -e "${BLU}  ➜  ${RST}$*"; }
success() { echo -e "${GRN}  ✔  ${RST}$*"; }
warn()    { echo -e "${YLW}  ⚠  ${RST}$*"; }
section() { echo -e "\n${CYN}══ $* ${RST}"; }

# ── pre-flight ───────────────────────────────────────────────
section "Pre-flight checks"

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) \
  || { echo -e "${RED}✖ Not inside a git repo — aborting.${RST}"; exit 1; }
cd "$ROOT"
success "Git root: $ROOT"

# Require a clean working tree (no uncommitted edits that could conflict)
if ! git diff --quiet || ! git diff --cached --quiet; then
  warn "Working tree has uncommitted changes."
  read -rp "  Continue anyway? Staged changes will be included in the commit. [y/N] " ans
  [[ $(echo "$ans" | tr '[:upper:]' '[:lower:]') == "y" ]] || { echo "Aborted."; exit 0; }
fi

# Confirm expected root dirs exist
for d in api-gateway async client_mobile gatekeeper monitoring wardrobe-service ai-service; do
  [[ -d "$d" ]] \
    || { echo -e "${RED}✖ Expected dir '$d' not found. Wrong root? Aborting.${RST}"; exit 1; }
done
success "All expected directories found"

# ── step 1: renames (git mv preserves history) ──────────────
section "Step 1 — Rename folders"

# 1a. async → task-worker  (reserved keyword in Python / JS / Java)
# Note: using plain mv — git mv fails on empty/untracked-only dirs.
# git add -A later detects the rename automatically via content similarity.
mv async task-worker
success "async  →  task-worker"

# 1b. client_mobile → client-mobile  (kebab-case consistency)
mv client_mobile client-mobile
success "client_mobile  →  client-mobile"

# 1c. gatekeeper/gatekeeper-iam-backend → gatekeeper/iam-backend  (remove redundant prefix)
mv gatekeeper/gatekeeper-iam-backend gatekeeper/iam-backend
success "gatekeeper/gatekeeper-iam-backend  →  gatekeeper/iam-backend"

# ── step 2: remove build artifacts ──────────────────────────
section "Step 2 — Remove build artifacts from tracking"

# After the rename in step 1c the path is now gatekeeper/iam-backend/target/
for artifact_path in \
  "gatekeeper/iam-backend/target" \
  "gatekeeper/target"; do
  if [ -d "$artifact_path" ]; then
    git rm -r --cached --ignore-unmatch "$artifact_path" > /dev/null 2>&1 \
      && info "Untracked from git:  $artifact_path"
    rm -rf "$artifact_path"
    success "Deleted from disk:   $artifact_path"
  else
    info "Not on disk (already clean): $artifact_path"
  fi
done

# ── step 3: update .gitignore ────────────────────────────────
section "Step 3 — Update .gitignore"

GITIGNORE="$ROOT/.gitignore"
touch "$GITIGNORE"

append_once() {
  # Appends $1 to .gitignore only if not already present (exact line match)
  grep -qxF "$1" "$GITIGNORE" || printf '\n%s' "$1" >> "$GITIGNORE"
}

# Make sure there's a trailing newline before we append
[[ -s "$GITIGNORE" ]] && [[ "$(tail -c1 "$GITIGNORE" | wc -l)" -eq 0 ]] \
  && echo "" >> "$GITIGNORE"

if ! grep -q "# ── Build / compiled output" "$GITIGNORE"; then
  cat >> "$GITIGNORE" << 'IGNORE_BLOCK'

# ── Build / compiled output ──────────────────────────────────
**/target/
**/.gradle/
**/build/
**/__pycache__/
**/*.pyc
**/*.class
**/*.jar

# ── Environment & secrets ────────────────────────────────────
**/.env
**/.env.local
**/.env.*.local
**/secrets/

# ── Logs & temp ──────────────────────────────────────────────
**/*.log
**/logs/
**/.DS_Store
**/Thumbs.db
IGNORE_BLOCK
  success ".gitignore updated with build-artifact and secret patterns"
else
  info ".gitignore already has build-artifact section — skipping"
fi

# ── step 4: monitoring sub-structure ────────────────────────
section "Step 4 — Scaffold monitoring sub-structure"

for d in monitoring/dashboards monitoring/alerts monitoring/exporters; do
  mkdir -p "$d"
  touch "$d/.gitkeep"
  success "Created: $d"
done

# ── step 5: new top-level directories ───────────────────────
section "Step 5 — Scaffold new top-level directories"

# infra/
mkdir -p infra/docker infra/k8s infra/terraform
touch infra/docker/.gitkeep infra/k8s/.gitkeep infra/terraform/.gitkeep
cat > infra/README.md << 'EOF'
# infra

| Directory   | Contents                                    |
|-------------|---------------------------------------------|
| `docker/`   | Dockerfiles & docker-compose files          |
| `k8s/`      | Kubernetes manifests (future)               |
| `terraform/`| Infrastructure-as-code (future)             |
EOF
success "Created: infra/{docker,k8s,terraform}"

# shared/
mkdir -p shared/proto shared/openapi shared/events
touch shared/proto/.gitkeep shared/openapi/.gitkeep shared/events/.gitkeep
cat > shared/README.md << 'EOF'
# shared

Cross-service contracts. Every service should import schemas from here
rather than duplicating them.

| Directory  | Contents                                |
|------------|-----------------------------------------|
| `proto/`   | Protobuf definitions (gRPC, future)     |
| `openapi/` | OpenAPI 3 specs for each service        |
| `events/`  | Async event / message schemas           |
EOF
success "Created: shared/{proto,openapi,events}"

# docs/
mkdir -p docs/adr docs/runbooks
cat > docs/README.md << 'EOF'
# docs

| Directory    | Contents                                              |
|--------------|-------------------------------------------------------|
| `adr/`       | Architecture Decision Records (use adr-tools format)  |
| `runbooks/`  | Operational runbooks for on-call                      |
EOF

cat > docs/adr/0001-monorepo-structure.md << 'EOF'
# ADR 0001 — Monorepo structure

**Date**: $(date +%Y-%m-%d)
**Status**: Accepted

## Context
All drape services live in a single repository for ease of cross-service
refactoring and unified CI pipelines during the early phase of the project.

## Decision
Kebab-case folder names, one folder per deployable unit, shared contracts
in `shared/`, infrastructure in `infra/`, docs in `docs/`.

## Consequences
All engineers work in the same repo. As the team grows this may be split
into a polyrepo, at which point the `shared/` directory becomes its own
package/registry.
EOF
touch docs/runbooks/.gitkeep
success "Created: docs/{adr,runbooks}"

# ── step 6: flutter lib feature structure ───────────────────
section "Step 6 — Scaffold Flutter lib structure"

# Only create if lib/ is currently empty (don't clobber existing code)
LIB_DIR="client-mobile/lib"
if [ -z "$(ls -A "$LIB_DIR" 2>/dev/null)" ]; then
  mkdir -p "$LIB_DIR/features" "$LIB_DIR/core" "$LIB_DIR/shared"
  touch "$LIB_DIR/features/.gitkeep" "$LIB_DIR/core/.gitkeep" "$LIB_DIR/shared/.gitkeep"
  success "Scaffolded: client-mobile/lib/{features,core,shared}"
else
  info "client-mobile/lib/ already has content — skipping scaffold"
fi

# ── optional step: remove unused Flutter desktop platforms ──
section "Optional — Remove unused Flutter platform targets"
warn "If this is a MOBILE-ONLY app, linux/ macos/ windows/ inside client-mobile are noise."
warn "Skip this block if you plan to ship a desktop version in the future."
read -rp "  Remove linux/, macos/, windows/ from client-mobile? [y/N] " rm_platforms
if [[ $(echo "$rm_platforms" | tr '[:upper:]' '[:lower:]') == "y" ]]; then
  for plat in linux macos windows; do
    if [ -d "client-mobile/$plat" ]; then
      git rm -r --cached --ignore-unmatch "client-mobile/$plat" > /dev/null 2>&1
      rm -rf "client-mobile/$plat"
      success "Removed: client-mobile/$plat"
    fi
  done
else
  info "Keeping desktop platform directories"
fi

# ── step 7: stage & commit ───────────────────────────────────
section "Step 7 — Stage and commit"

git add -A

echo ""
echo "  Staged diff summary:"
git diff --cached --stat | sed 's/^/    /'

echo ""
read -rp "  Commit these changes? [Y/n] " do_commit
if [[ $(echo "$do_commit" | tr '[:upper:]' '[:lower:]') != "n" ]]; then
  git commit -m "refactor(monorepo): restructure folders, remove artifacts, scaffold dirs

Renames
- async/                              → task-worker/
- client_mobile/                      → client-mobile/
- gatekeeper/gatekeeper-iam-backend/  → gatekeeper/iam-backend/

Cleanup
- Remove gatekeeper/**/target/ build artifacts from tracking
- Add comprehensive .gitignore entries for build output & secrets

New structure
- monitoring/{dashboards,alerts,exporters}
- infra/{docker,k8s,terraform}
- shared/{proto,openapi,events}
- docs/{adr,runbooks}  (ADR 0001 included)
- client-mobile/lib/{features,core,shared} (if lib was empty)

No logic changed — rename-only commits preserve full git history."

  success "Committed!"
  echo ""
  echo "  Last commit:"
  git log --oneline -1 | sed 's/^/    /'
  echo ""
  echo "  Push with:"
  echo "    git push origin \$(git branch --show-current)"
else
  warn "Changes staged but NOT committed. Run 'git commit' manually when ready."
fi

echo ""
echo -e "${GRN}══ Done! New structure:${RST}"
tree -d --noreport -L 2 "$ROOT" 2>/dev/null || find "$ROOT" -maxdepth 2 -type d | sort