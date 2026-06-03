---
name: auto-model
description: Guides the user in discovering a better model structure (e.g. from feature transformations in logistic regression to equation terms within PDEs to neural network layer compositions) out of data. Use when the user asks to create or improve an existing model. Uses an iterative meta/inner agent loop to explore structural model modifications in parallel.
license: Apache-2.0
---

# auto-model
A structured guide to discovering models from data with agents.
Focuses on the structure of the model (be it equation terms or neural network layers) rather than just parameter values, using an iterative meta/inner agent loop to explore structural modifications in parallel. Applies to a wide range of tasks, from simple regression to complex physical systems, from automotive to pharmacology.

---

## Phases

This skill is organized into four sequential phases, each with a detailed recipe in `assets/phases/`:

| Phase | Recipe | Entry signal |
|---|---|---|
| **1 — Setup** | `assets/phases/1_setup.md` | Default starting point |
| **2 — First Model** | `assets/phases/2_first_model.md` | Train/val/test splits exist, or a `model.X` file exists |
| **3 — Iterate** | `assets/phases/3_iterate.md` | `CONTEXT.md` exists in the project root |
| **4 — Finalize** | `assets/phases/4_finalize.md` | User satisfied with validation performance |

Each phase ends with a context dump to `CONTEXT.md` and a history compact — use these as re-entry signals when resuming.

---

## How to start

1. Copy `assets/CHECKLIST.md` to the project root (if not already present) and update it as you go.
2. Detect the current phase using the entry signals above. If a checklist with partial progress is already present, ask the user whether to resume.
3. Read **only the frontmatter** of all phase files to confirm which one applies — do not load the full recipes yet:
   ```bash
   # bash / zsh
   bash scripts/read_phases.sh
   ```
   ```powershell
   # PowerShell
   pwsh scripts/read_phases.ps1
   ```
   The frontmatter `entry`, `exit`, and `description` fields are sufficient to identify the applicable phase without loading full recipes into context.
4. Once the applicable phase is confirmed, load and follow its full recipe (`assets/phases/<N>_<name>.md`).
