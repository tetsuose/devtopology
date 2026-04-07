# Monorepo Example

A multi-module project with 5 modules at different maturity stages, demonstrating scope enforcement and module-level contracts.

## Structure

```
monorepo/
├── guardrails.yaml
├── docs/runtime/File-Contracts.json    # 8 entries across 5 modules
├── Makefile
├── api/                                # Go HTTP API (implemented)
│   ├── handler.go
│   └── middleware.go
├── web/                                # React frontend (mixed stages)
│   └── src/
│       ├── App.tsx                     # implemented
│       └── hooks/useApi.ts             # planned
├── shared/                             # Shared types (verified)
│   └── types.go
├── worker/                             # Background jobs (baseline)
│   └── processor.go
└── deploy/                             # Infrastructure (implemented)
    └── docker-compose.yaml
```

## What this shows

### Multiple modules with different stages

| Module | Files | Stage | Meaning |
|--------|-------|-------|---------|
| api | 2 | implemented | Working, contracts filled |
| web | 2 | mixed | App.tsx implemented, useApi.ts still planned |
| shared | 1 | verified | Stable, tests confirm correctness |
| worker | 1 | baseline | Code exists but contracts are minimal |
| deploy | 1 | implemented | Working local dev setup |

### Scope enforcement

Restrict an agent to only the `api` module:

```bash
make enforce-fill MODULE=api
# GATE_PASS gate=fill_queue_scope ... module=api
```

If the agent touches `web/src/App.tsx`, the gate fails:

```bash
# GATE_FAIL gate=fill_queue_scope ... violations=1 fix="Constrain edits to allowed module/stages."
```

### Stage-based gating

Only allow work on files in `planned` or `implemented` stages:

```bash
make enforce-fill MODULE=web STAGES=planned,implemented
```

This permits work on `useApi.ts` (planned) and `App.tsx` (implemented) but would block changes to files that are already `verified` or `done`.
