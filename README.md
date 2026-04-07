# repo-guardrails

Structure-aware guardrails for AI coding agents.

AI agents drift. They forget your repo topology, revert to old paths, create redundant files, and touch modules they shouldn't. **repo-guardrails** solves this with machinery, not instructions.

## What it does

| Problem | Solution |
|---------|----------|
| Agent forgets repo structure across sessions | **Mirror/Atlas** generates a real-time topology map from git |
| Agent creates files without documenting them | **File-Contracts** tracks purpose/invariants/verification per file |
| Files are added/removed but contracts go stale | **Writeback** detects and fixes contract drift automatically |
| Agent modifies code outside its task scope | **Enforce-Fill** gates changes to a declared module |
| Parallel tasks pollute each other | **Worktree isolation** gives each task its own sandbox |
| Gates produce unstructured output | **Gate Report** parses `GATE_PASS`/`GATE_FAIL` into structured JSON |

## Quick Start (5 minutes)

```bash
# 1. Copy into your project
cp -r engine/ scripts/ Makefile guardrails.yaml docs/ /path/to/your-repo/

# 2. Initialize contracts for all existing files
cd /path/to/your-repo
make writeback-apply WRITE=1

# 3. See your repo through the agent's eyes
make start QUERY="understand project structure"

# 4. Check health
make verify
```

No dependencies beyond Python 3.8+ and git.

## Commands

### Structure Awareness

```bash
make start QUERY="..."       # Generate atlas-pack + detect contract drift
make mirror                  # File inventory with sha256, line counts, module/kind
make atlas                   # Module/kind/stage aggregation
make context QUERY="..."     # LLM-readable markdown context
```

### Contract Enforcement

```bash
make verify                  # structure_contract_coverage + changed_file_contract_semantics
make health                  # Full health summary
make health-strict           # Same, but exit non-zero on any gate failure
make gate-report LOG=...     # Parse GATE_PASS/FAIL lines into JSON
```

### Drift Repair

```bash
make writeback-preview       # Show missing/stale file contracts (read-only)
make writeback-apply WRITE=1 # Sync File-Contracts.json with actual repo files
```

### Scope Gate

```bash
make enforce-fill MODULE=api               # Only allow changes in the "api" module
make enforce-fill MODULE=api STAGES=implemented,verified  # Restrict by stage too
```

### Task Isolation

```bash
make task-open QUERY="add auth endpoint"   # Create worktree + branch
make task-status                            # Print branch, dirty count, ahead/behind
make task-check                             # Fail if uncommitted changes exist
make task-close                             # Check PR status, suggest next action
```

## How It Works

### File-Contracts.json

Every file in your repo gets a contract entry:

```json
{
  "path": "api/auth/handler.go",
  "kind": "code",
  "module": "api",
  "stage": "implemented",
  "contract": {
    "purpose": "Handle OAuth2 callback and issue session tokens",
    "invariants": "Never stores raw tokens; always hashes before DB write",
    "verification": "go test ./api/auth/ covers happy path + expired token"
  }
}
```

Stages track maturity: `scaffolded` > `baseline` > `planned` > `implemented` > `verified` > `done`.

### Gates

All gates output a structured line:

```
GATE_PASS gate=structure_contract_coverage files=142
GATE_FAIL gate=changed_file_contract_semantics violations=3 fix="Fill purpose/invariants/verification"
```

These are machine-parseable. `make gate-report` collects them into a JSON report.

### Three Gates

1. **structure_contract_coverage** -- every file has a contract entry (no missing, no stale)
2. **changed_file_contract_semantics** -- every changed file has non-placeholder purpose/invariants/verification
3. **fill_queue_scope** -- changed files belong to the declared module and allowed stages

## Configuration

`guardrails.yaml` at your repo root:

```yaml
ledger: docs/runtime/File-Contracts.json
index_dir: .index
exclude:
  - "vendor/"
  - "node_modules/"
fill_allowed_stages:
  - planned
  - implemented
  - verified
  - done
fill_exempt:
  - "docs/runtime/File-Contracts.json"
protected_branches:
  - main
  - develop
```

## Output Artifacts

```
.index/                              # gitignored, generated
  mirror/project-mirror-latest.json  # full file inventory
  atlas/repo-atlas-latest.json       # module/kind/stage breakdown
  context/atlas-pack-latest.md       # LLM context summary
  contracts/file-contracts-latest.json
  writeback/                         # drift reports
  health/                            # gate results
```

## Design Principles

- **Machinery over instructions.** Don't tell the agent "don't touch module X" -- physically gate it.
- **Zero dependencies.** Python stdlib only. Runs anywhere git and Python exist.
- **Gates, not suggestions.** `GATE_FAIL` is a hard signal, not a warning to ignore.
- **Drift detection, not drift prevention.** Files change. Detect the mismatch, fix it, move on.
- **One task, one worktree.** Isolation prevents cross-task contamination.

## License

MIT
