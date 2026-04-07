SHELL := /bin/bash
export PYTHONDONTWRITEBYTECODE := 1

.PHONY: help start mirror atlas context verify health health-strict \
        writeback-preview writeback-apply enforce-fill gate-report \
        task-open task-check task-status task-close

ENGINE ?= engine/index.py
QUERY ?=
LOG ?= .index/health/verify-output-latest.log
MODULE ?=
STAGES ?= planned,implemented,verified,done
TASK_KIND ?= task
BASE ?= origin/main
WORKTREE_ROOT ?= ../.worktrees

help:
	@echo ""
	@echo "  StructGate — structure-aware gates for AI coding agents"
	@echo ""
	@echo "  Structure Awareness"
	@echo "    make start QUERY='...'        Generate atlas-pack + detect drift"
	@echo "    make mirror                   File-level inventory (JSON)"
	@echo "    make atlas                    Module/kind/stage aggregation (JSON)"
	@echo "    make context QUERY='...'      LLM-readable context (Markdown)"
	@echo ""
	@echo "  Contract Enforcement"
	@echo "    make verify                   Run structure + semantic gates"
	@echo "    make health                   Full health summary"
	@echo "    make health-strict            Health + non-zero exit on failure"
	@echo "    make gate-report LOG=...      Parse GATE_PASS/FAIL from log"
	@echo ""
	@echo "  Drift Repair"
	@echo "    make writeback-preview        Preview missing/stale contracts"
	@echo "    make writeback-apply WRITE=1  Sync File-Contracts.json"
	@echo ""
	@echo "  Scope Gate"
	@echo "    make enforce-fill MODULE=...  Restrict changes to one module"
	@echo ""
	@echo "  Task Isolation"
	@echo "    make task-open QUERY='...'    Create worktree + branch"
	@echo "    make task-check               Fail if worktree is dirty"
	@echo "    make task-status              Print branch/worktree state"
	@echo "    make task-close               Check PR status + next action"
	@echo ""

# --- Structure Awareness ---

start:
	@python3 $(ENGINE) start --query "$(QUERY)"

mirror:
	@python3 $(ENGINE) mirror

atlas:
	@python3 $(ENGINE) atlas

context:
	@python3 $(ENGINE) context --query "$(QUERY)"

# --- Contract Enforcement ---

verify:
	@mkdir -p .index/health
	@set -o pipefail; python3 $(ENGINE) verify | tee .index/health/verify-output-latest.log

health:
	@mkdir -p .index/health
	@set -o pipefail; python3 $(ENGINE) health | tee .index/health/health-output-latest.log

health-strict:
	@mkdir -p .index/health
	@set -o pipefail; python3 $(ENGINE) health --strict | tee .index/health/health-output-latest.log

gate-report:
	@python3 $(ENGINE) gate-report --log "$(LOG)"

# --- Drift Repair ---

writeback-preview:
	@python3 $(ENGINE) writeback-preview

writeback-apply:
	@WRITE=$(WRITE) python3 $(ENGINE) writeback-apply

# --- Scope Gate ---

enforce-fill:
	@WRITE=$(WRITE) python3 $(ENGINE) enforce-fill --module "$(MODULE)" --allowed-stages "$(STAGES)"

# --- Task Isolation ---

task-open:
	@STRUCTGATE_BASE="$(BASE)" STRUCTGATE_WORKTREE_ROOT="$(WORKTREE_ROOT)" \
		bash scripts/worktree.sh open --query "$(QUERY)" --kind "$(TASK_KIND)" --base "$(BASE)" --root "$(WORKTREE_ROOT)"

task-check:
	@bash scripts/worktree.sh check

task-status:
	@STRUCTGATE_BASE="$(BASE)" bash scripts/worktree.sh status --base "$(BASE)"

task-close:
	@STRUCTGATE_BASE="$(BASE)" bash scripts/worktree.sh close --base "$(BASE)"
