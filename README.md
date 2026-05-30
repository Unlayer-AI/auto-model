# auto-model

A skill to guide agents in building interpretable, mechanistic models from data. Covers everything from goal definition to iterative model improvement with parallel sub-agents, through to final test-set evaluation. Designed for a wide range of tasks — from simple regression to complex physical systems (automotive, pharmacology, biomechanics, etc.) — using mathematical/structural models, not black-box neural networks.

Built following the [Complete Guide to Building Skills for Claude](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf).

---

## Structure

```
auto_model/
  SKILL.md                  # Skill entry point: phase table, entry signals, how to start
  assets/
    checklist.md            # Progress tracker — copy to project root when starting
    phases/
        setup.md                # Phase 1: goal, data, metrics, optimization routine
        first_model.md          # Phase 2: mock model, sub-agent pipeline test, sanity check
        iterate.md              # Phase 3: meta/inner agent loop (core of the skill)
        finalize.md             # Phase 4: test-set evaluation, FINAL.md
```

---

## Phases

| Phase | Recipe | Entry signal |
|---|---|---|
| **1 — Setup** | `assets/phases/1_setup.md` | Default starting point |
| **2 — First Model** | `assets/phases/2_first_model.md` | Train/val/test splits exist, or a `model.X` file exists |
| **3 — Iterate** | `assets/phases/3_iterate.md` | `CONTEXT.md` exists in the project root |
| **4 — Finalize** | `assets/phases/4_finalize.md` | User satisfied with validation performance |

Each phase ends with a context dump to `CONTEXT.md` and a history compact, enabling clean resumption.

The agent reads only the YAML frontmatter of a phase file to confirm the right phase before loading the full recipe:
```bash
awk 'NR>1{if(/^---$/)exit; print}' auto_model/assets/phases/1_setup.md
```

---

## How to use

Install the skill by pointing your Claude agent config to `auto_model/SKILL.md`, or copy the `auto_model/` folder into your project's `.claude/skills/` directory.

See `examples/friction/` for a worked example applying the skill to tire friction model calibration.

---

## License

CC-BY-4.0
