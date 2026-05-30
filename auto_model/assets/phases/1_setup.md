---
name: setup
entry: No existing project artifacts, or splits exist but no model yet
exit: Optimization routine exists; CONTEXT.md created; history compacted
description: First phase. Review/establish goal and domain lingo with user, identify and prepare data splits, define metrics and loss function, implement parameter optimization routine.
---

# Phase 1 — Setup

---

## Steps

### 1. Goal
Review with the user:
- Context, intended goal, and scope of the model
- Programming language/software to use; confirm runtime supports it and required libraries are installed
- Domain lingo to use throughout (e.g. *loss function* vs. *cost function* / *features* vs. *covariates* / *training* vs. *calibration*)

### 2. Existing code
If any code already exists, review it with the user: decide whether to reuse or rewrite. Use these signals to decide where to skip within this phase: if train/val/test split files exist → skip to Metrics; if an optimization routine exists → skip to the context dump below.

### 3. Data
Identify:
- Where the data lives and which files/tables are relevant
- Intended input and output variables
- Whether data is present, sufficient, and clean; flag any cleaning needs
- A split strategy that produces `train.X`, `validation.X`, and `test.X` (e.g. `.csv`, `.mat`, `.rdata`) stored in a consistent location

### 4. Metrics
Define with the user:
- Objective/loss function for training/calibration
- Evaluation metrics for the validation and test sets
- *Always include run-time and memory usage as metrics* — these gate the feasibility of the iterative loop

### 5. Optimization routine
Implement (or confirm existing) a parameter optimization routine, e.g. gradient descent or a black-box method (PSO, Nelder-Mead). Prefer libraries over from-scratch implementations.

---

## Context dump (end of phase)

Create `CONTEXT.md` in the project root using `assets/CONTEXT.md` as a starting point. Fill in the Phase 1 sections:
- Goal and scope
- Language/runtime and key libraries
- Data location, variable names, split strategy
- Chosen loss/cost/objective function and evaluation metrics
- Brief description of the optimization routine

Then **compact your conversation history** before proceeding to Phase 2 — First Model (if auto-compact is not enabled, ask the user to trigger it).
