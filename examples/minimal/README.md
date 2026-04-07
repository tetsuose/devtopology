# Minimal Example

A single-module project with three files demonstrating the basics of StructGate.

## Structure

```
minimal/
├── structgate.yaml                    # Config (only ledger + exclusions)
├── docs/runtime/File-Contracts.json   # Ledger with 3 entries
├── app.py                             # Application code
├── config.yaml                        # Application config
└── tests/test_app.py                  # Tests
```

## What this shows

- Each file has a contract with real `purpose`, `invariants`, and `verification`
- Stages reflect actual maturity: config is `verified`, code and tests are `implemented`
- No placeholder values — `make verify` would pass both gates

## To use as a starting point

1. Copy `engine/`, `scripts/`, and `Makefile` from the StructGate root into your project
2. Copy `structgate.yaml` and `docs/runtime/File-Contracts.json` as templates
3. Run `make writeback-apply WRITE=1` to auto-discover your actual files
4. Fill in contracts for each file
