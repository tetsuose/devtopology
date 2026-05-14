<div align="center">

# DevTopology

**Development topology for AI coding agents.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Python 3.8+](https://img.shields.io/badge/Python-3.8+-green.svg)](https://python.org)
[![Zero Dependencies](https://img.shields.io/badge/Dependencies-Zero-brightgreen.svg)](#design-principles)

</div>

---

AI coding agents drift. They forget your repo topology, revert to old paths, create files without contracts, and touch modules they shouldn't.

**DevTopology** fixes this with **hard gates**, not soft instructions. Every file gets a contract. Every change is verified. Every scope violation is blocked.

## Why DevTopology?

- **Living blueprint.** Mirror + Atlas build a real-time topology map of your codebase from git.
- **File-level contracts.** Every file has a documented purpose, invariants, and verification method.
- **Hard gates.** `GATE_FAIL` stops the agent. It's not a warning to ignore.
- **Automatic drift detection.** Files change. DevTopology detects the mismatch and fixes it.
- **Module scope enforcement.** Physically prevent the agent from touching code outside its task.
- **Zero dependencies.** Python stdlib only. No pip install, no Docker, no cloud.

## Quick Start

```bash
# 1. Copy into your project
cp -r engine/ scripts/ gate/ Makefile devtopology.yaml docs/ your-project/

# 2. Initialize contracts for all existing files
cd your-project
make writeback-apply WRITE=1

# 3. Generate the repo topology map
make start QUERY="understand project structure"

# 4. Verify all gates pass
make verify
```

**Expected output:**

```
GATE_PASS gate=structure_contract_coverage files=42
GATE_PASS gate=changed_file_contract_semantics changed=0 validated=0
```

No `pip install`. No Docker. Just Python 3.8+ and git.

## How It Works

### 1. Every file gets a contract

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

Contracts live in `docs/runtime/File-Contracts.json` (tracked in git). Stages track maturity:

`scaffolded` > `baseline` > `planned` > `implemented` > `verified` > `done`

### 2. Gates enforce the contracts

All gates output a machine-parseable line:

```
GATE_PASS gate=structure_contract_coverage files=142
GATE_FAIL gate=changed_file_contract_semantics violations=3 fix="Fill purpose/invariants/verification"
```

| Gate | What it checks |
|------|---------------|
| **structure_contract_coverage** | Every file has a contract entry. No missing, no stale. |
| **changed_file_contract_semantics** | Every changed file has non-placeholder purpose/invariants/verification. |
| **fill_queue_scope** | Changed files belong to the declared module and allowed stages. |

### 3. Drift is detected and fixed automatically

```bash
make writeback-preview       # See what's missing/stale (dry run)
make writeback-apply WRITE=1 # Fix it — add missing entries, retire stale ones
```

## Commands

<details open>
<summary><strong>Structure Awareness</strong></summary>

```bash
make start QUERY="..."       # Generate topology + detect drift
make mirror                  # File inventory: sha256, lines, module, kind
make atlas                   # Module/kind/stage aggregation
make context QUERY="..."     # LLM-readable markdown context
```

</details>

<details open>
<summary><strong>Contract Enforcement</strong></summary>

```bash
make verify                  # Run all gates
make health                  # Full health summary
make health-strict           # Health + non-zero exit on failure
make gate-report LOG=...     # Parse GATE_PASS/FAIL into JSON
```

</details>

<details>
<summary><strong>Scope Gate</strong></summary>

```bash
make enforce-fill MODULE=api                              # Restrict to one module
make enforce-fill MODULE=api STAGES=implemented,verified  # Restrict by stage too
```

</details>

<details>
<summary><strong>Task Isolation</strong></summary>

```bash
make task-open QUERY="add auth endpoint"   # Create worktree + branch
make task-status                            # Branch, dirty count, ahead/behind
make task-check                             # Fail if uncommitted changes
make task-close                             # Check PR status, suggest next action
```

</details>

## Configuration

`devtopology.yaml` at your project root:

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

## Agent Integration

DevTopology works with any AI coding agent that reads markdown instructions:

| Agent | Integration |
|-------|------------|
| **Claude Code** | `CLAUDE.md` + `skills/devtopology/SKILL.md` (included) |
| **Codex / Cursor / Copilot / Gemini CLI** | `AGENTS.md` (included, [open standard](https://agents.md)) |
| **Any agent** | Run `make start` and feed the output as context |

## Architecture

```
devtopology.yaml              # Configuration (all paths configurable)
engine/index.py              # Core engine (~1050 lines, Python stdlib only)
scripts/worktree.sh           # Task isolation (git worktrees)
gate/report.sh               # Standalone bash gate parser
docs/runtime/
  File-Contracts.json        # The ledger (tracked in git)
  Manifest-Contract-System.md # Contract system reference
  Credentials-Management.md   # Credential plane model + lifecycle (advisory)
  Env-Registry.example.md     # Names-only env registry template
  Secrets-Inventory.example.yaml # Operational asset + credential inventory template
.index/                      # Generated artifacts (gitignored)
  mirror/   atlas/   context/   contracts/   writeback/   health/
```

### Credentials

File contracts cover source files. They do not cover the runtime secrets your code reads at boot. The credentials layer is a parallel doc-and-template system:

- **Credential planes** — every runtime secret belongs to exactly one plane (operator-control, runtime source-of-truth, mirror, incoming-staging, consumer-specific, out-of-band backend). Planes have hard boundaries.
- **Names-only registry** — `docs/runtime/Env-Registry.md` records `env_key | source_file | runtime_injection | primary_consumers | verify_gate`. Never values.
- **Inventory** — `secrets-inventory.yaml` lists assets and credentials with rotation timestamps. Stored outside git; only the `.example.yaml` template is committed.

See [Credentials-Management.md](docs/runtime/Credentials-Management.md) for the full model and lifecycle (incoming-staging workflow, rotation classes, atomic dual-backend rotation).

## Design Principles

- **Machinery over instructions.** Don't tell the agent "don't touch module X" — physically gate it.
- **Zero dependencies.** Python stdlib only. No pip install, no Docker, no cloud.
- **Deterministic, not probabilistic.** Gates are hard pass/fail. No vector search, no LLM calls.
- **Drift detection, not prevention.** Files change. Detect the mismatch, fix it, move on.
- **One task, one worktree.** Isolation prevents cross-task contamination.

## Examples

See [`examples/minimal/`](examples/minimal/) for a single-module setup, or [`examples/monorepo/`](examples/monorepo/) for multi-module scope enforcement.

## License

[MIT](LICENSE)
