# AGENTS.md — StructGate

> Structure-aware gates for AI coding agents.

## Before starting work

```bash
make start QUERY="<your task>"
```

If `GATE_FAIL gate=structure_contract_coverage` appears:

```bash
make writeback-apply WRITE=1
```

## While working

- **New files:** Run `make writeback-apply WRITE=1` to register them, then fill their contracts in `docs/runtime/File-Contracts.json`.
- **Changed files:** Update the contract (`purpose`, `invariants`, `verification`) if the file's role changed.
- **Scope enforcement:** If assigned a module via `make enforce-fill MODULE=<name>`, only modify files in that module.

## Before committing

```bash
make verify
```

Both gates must pass (`GATE_PASS`). Do not commit on `GATE_FAIL`.

## Contract format

Every file has an entry in `docs/runtime/File-Contracts.json`:

```json
{
  "path": "src/handler.go",
  "kind": "code",
  "module": "src",
  "stage": "implemented",
  "contract": {
    "purpose": "What this file does (one sentence)",
    "invariants": "What must remain true (constraints, not implementation)",
    "verification": "How to confirm correctness"
  }
}
```

## Stages

`scaffolded` > `baseline` > `planned` > `implemented` > `verified` > `done`

## Key commands

| Command | Purpose |
|---------|---------|
| `make start QUERY="..."` | Load topology + detect drift |
| `make verify` | Run all gates |
| `make writeback-apply WRITE=1` | Sync ledger with files |
| `make enforce-fill MODULE=...` | Restrict scope to module |
| `make task-open QUERY="..."` | Create isolated worktree |

## Rules

- `GATE_FAIL` is a hard stop, not a suggestion
- No placeholder contracts (`TODO`, `TBD`) in changed files
- One task, one worktree
