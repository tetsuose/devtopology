# repo-guardrails skill

Structure-aware guardrails for AI coding agents. This skill enforces file contracts, drift detection, and scope constraints.

## Workflow

### Before starting work

Run `make start QUERY="<your task>"` to load repo topology and detect drift. If `GATE_FAIL gate=structure_contract_coverage` appears, run `make writeback-apply WRITE=1` first.

### While working

1. **Stay in scope.** If a module is assigned via `make enforce-fill MODULE=<name>`, only modify files in that module.
2. **Update contracts.** When you create or substantially change a file, update its contract in `docs/runtime/File-Contracts.json`:
   - `purpose` — what the file does (one sentence)
   - `invariants` — what must remain true (constraints, not implementation)
   - `verification` — how to confirm correctness
3. **Advance stages.** Move files through `scaffolded` > `baseline` > `planned` > `implemented` > `verified` > `done` as work progresses. Never skip more than one stage.
4. **New files.** After creating files, run `make writeback-apply WRITE=1` to register them in the ledger. Then fill their contracts.

### Before committing

Run `make verify`. Both gates must pass:

- `GATE_PASS gate=structure_contract_coverage` — every file has a ledger entry, no stale entries
- `GATE_PASS gate=changed_file_contract_semantics` — every changed file has non-placeholder contracts

If a gate fails, fix the issue before committing. Do not skip gates.

### Task isolation

For parallel tasks, use worktrees:

```bash
make task-open QUERY="add auth endpoint"   # creates branch + worktree
# ... do work in the worktree ...
make task-check                             # fail if dirty
make task-close                             # check PR status, suggest next action
```

## Key files

| File | Role |
|------|------|
| `guardrails.yaml` | Project config — exclusions, protected branches, gate settings |
| `docs/runtime/File-Contracts.json` | The ledger — tracked in git, one entry per file |
| `engine/index.py` | Core engine — mirror, atlas, contracts, gates, writeback |
| `scripts/worktree.sh` | Task isolation via git worktrees |

## Gate output format

All gates emit structured lines. Parse them, don't regex logs:

```
GATE_PASS gate=<name> <key>=<value> ...
GATE_FAIL gate=<name> <key>=<value> ... fix="<remediation>"
```

## Rules

- Never commit with `GATE_FAIL` in verify output
- Never leave placeholder contracts (`TODO`, `TBD`, `...`) in changed files
- Never add external Python dependencies to `engine/index.py`
- Always run `make writeback-apply WRITE=1` after adding or removing files
- Contracts describe *what* and *why*, not *how* — no implementation details in contracts
