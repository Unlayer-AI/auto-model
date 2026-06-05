---
name: iterate
description: Third and main phase. Orchestrate meta/inner agent loop. Guide user in choosing iteration parameters, spawn S parallel sub-agents per meta-iteration each running I sequential structural modifications, review results across agents, and repeat for M meta-iterations until user is satisfied with validation performance.
entry: CONTEXT.md exists; end-to-end pipeline verified
exit: User satisfied with validation performance; CONTEXT.md updated with final summary; history compacted
---

# Phase 3 — Iterate

---

## Setup (once, with user)

Read `CONTEXT.md` to restore context. Then:

1. Use the confirmed run-time per optimization step and memory usage to estimate total compute for a full loop (account for sub-agents working in parallel, and for sub-agent thinking and writing overhead of a few seconds per step).
2. Guide the user in choosing:
   - **M** — number of meta-iterations
   - **S** — number of sub-agents per meta-iteration (run in parallel)
   - **I** — number of inner iterations per sub-agent (run sequentially)

---

## Execution — meta loop

For each meta-iteration `m = 1 … M`:

### 1. Spawn sub-agents
Launch **S sub-agents in parallel**. Each agent writes exclusively within its own `meta_m/agent_s/` directory to avoid file conflicts.

Provide each sub-agent with:
- If `m = 1`, the baseline model file; if `m > 1`, the best model from `meta_(m-1)/agent_s` + respective evaluation results
- A distinct hypothesis or search direction (ensure agents don't duplicate effort)
- The evaluation protocol: train on `train.X`, evaluate on both `train.X` and `validation.X`, log all metrics

### 2. Sub-agent inner loop (I iterations each)
Each sub-agent, for `i = 1 … I`:
1. Plan a *structural* modification to the model — at the level of equations or code functions (e.g. new term, different functional form, changed coupling), based on the previous attempt's evaluation results. Store in `meta_m/agent_s/attempt_i/plan.md`.
2. Implement the modified model in `meta_m/agent_s/attempt_i/model.X`.
3. Train/calibrate on `train.X` using the optimization routine; store metrics and optimal parameters in `meta_m/agent_s/attempt_i/training.md`.
4. Evaluate on `train.X` and `validation.X`; store results in `meta_m/agent_s/attempt_i/evaluation.md`.
5. Proceed to next iteration.

### 3. Meta-iteration review (no user involvement)
Once all S agents complete their I iterations:
- Review each agent's final `plan.md` and `evaluation.md`
- Identify which structural changes improved performance and which didn't
- Formulate hypotheses for the next meta-iteration; ensure next-iteration agent prompts cover non-overlapping search directions

### 4. Context dump (each meta-iteration)
**Append** to `CONTEXT.md`:
- Meta-iteration index and best validation metric achieved
- Summary of structural changes that worked / didn't work
- Hypotheses and search directions for the next meta-iteration (if an agent is stuck, prompt it to explore a different direction)

---

## Review with user (after M meta-iterations)

Present:
- Plots of training and validation performance of the best model found at each meta-iteration
- Summary of structural changes that drove improvements

Ask the user:
- **Continue iterating?** → return to Setup above, choosing new M/S/I; increment meta-iteration index to `M+1` to avoid overwriting previous logs; compact history before starting.
- **Satisfied with validation performance?** → proceed to Phase 4 — Finalize.

---

## Context dump (before handing off to Finalize)

Update `CONTEXT.md` with:
- Path to the best model file and its validation metrics
- Final search summary: what was tried, what worked, rationale for stopping

Then **compact your conversation history** before proceeding to Phase 4 — Finalize (if auto-compact is not enabled, ask the user to trigger it).
