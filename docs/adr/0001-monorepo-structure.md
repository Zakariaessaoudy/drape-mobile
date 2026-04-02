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
