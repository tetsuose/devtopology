# CLAUDE.md — repo-guardrails

## What this project is

A structure-aware guardrails framework for AI coding agents. Zero external dependencies (Python stdlib + bash + git only).

## Key commands

```bash
make start QUERY="..."        # Generate atlas-pack + detect drift (run this first)
make verify                   # Run structure + semantic gates
make writeback-apply WRITE=1  # Sync File-Contracts.json with actual files
make health                   # Full health summary
```

## Architecture

- `engine/index.py` — Core engine (~1050 lines). Mirror/Atlas/Contracts/Writeback/Gates pipeline.
- `scripts/worktree.sh` — Task isolation via git worktrees.
- `Makefile` — Thin orchestration layer. All targets delegate to the above two.
- `guardrails.yaml` — Project config. All paths/exclusions/branches configurable here.
- `docs/runtime/File-Contracts.json` — The ledger. Tracked in git. Every file gets a contract entry.

## Rules

- **Zero dependencies.** Never add pip packages. Use Python stdlib only.
- **No personal info.** No usernames, emails, domains, or machine-specific paths in any file.
- **No domain coupling.** This is a generic tool. Never reference VPN, proxy, or any specific domain.
- **Gate output is structured.** Always use `GATE_PASS gate=... ` / `GATE_FAIL gate=...` format.
- **Contracts are not optional.** Every file must have a non-placeholder contract before shipping.
- **Run `make writeback-apply WRITE=1`** after adding/removing files to keep the ledger in sync.
- **Run `make verify`** before committing to ensure gates pass.

## File stages

`scaffolded` → `baseline` → `planned` → `implemented` → `verified` → `done` → `deprecated`

## Generated artifacts

`.index/` is gitignored. Contains mirror, atlas, context, contracts, health, writeback outputs.
