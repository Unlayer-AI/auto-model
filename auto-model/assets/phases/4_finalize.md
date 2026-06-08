---
name: finalize
description: Fourth and final phase. Evaluate the best model on the held-out test set, decide whether to return to Iterate or accept results, and produce FINAL.md summarizing the model and key findings.
entry: User satisfied with validation performance; CONTEXT.md has pointer to best model
exit: FINAL.md created; CONTEXT.md updated with test metrics.
---

# Phase 4 — Finalize

---

## Steps

### 1. Restore context
Read `CONTEXT.md` to identify the best model path and its validation performance.

### 2. Final test-set evaluation
Evaluate the best model on `test.X`. Report all metrics defined in Phase 1 (including run-time and memory).

### 3. Decide
- If test performance is significantly worse than validation: discuss with the user whether to return to Phase 3 — Iterate (suggest to the user to gather new data to use as a fresh test set to prevent overfitting via repeated evaluation!).
- If test performance is acceptable: finalize.

### 4. FINAL.md
Create `FINAL.md` in the project root using `assets/FINAL.md` as a starting point. Fill in:
- Decision, goal, and concise result summary
- Selected model path, structure summary, rationale, and usage entry point
- Baseline validation, final validation, and final test metrics
- Acceptance-criteria results and interpretation of the validation-to-test difference
- Most important limitation, next step, and reproducibility pointers

Keep `FINAL.md` concise and decision-focused. Link to `CONTEXT.md` for the full search history instead of repeating individual experiments or meta-iteration details.

## Context dump (end of phase)

Update `CONTEXT.md` with the final test metrics and a pointer to `FINAL.md`.
