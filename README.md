<img src="assets/auto-model.png" alt="a cute robot sculpting a wooden horse under the supervision of a girl" width="600"/>

# auto-model

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-2ea44f.svg)](LICENSE)
![Status: Experimental](https://img.shields.io/badge/Status-Experimental-f39c12.svg)
![Type: Agent Skill](https://img.shields.io/badge/Type-Agent%20Skill-1f6feb.svg)
![Workflow: Meta/Inner Loop](https://img.shields.io/badge/Workflow-Meta%2FInner%20Loop-8a2be2.svg)

`auto-model` is meant to be a practical skill for building or improving a model from data with agents. It focuses on the structure of the model (be it equation terms or neural network layers) rather than just parameter values, and strives to apply to a wide range of tasks, from simple regression to complex physical systems in a wide range of fields (automotive, pharmacology, ...).

The skill tries to be reasonably comprehensive, guiding the agent from problem setup to iterative model improvement with parallel sub-agents, and ends with holdout test-set evaluation.

Built following the [Complete Guide to Building Skills for Claude](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf).

## At a glance

- What it is: an agent skill that helps you discover or improve model structure from data (not just tune parameters).
- How it works: a 4-phase loop - setup, first model, iterative improvement with parallel agents, then final holdout evaluation.
- What you get: a documented search history, candidate model files, evaluation notes, and a final test-set report.
- Best for: contained modeling tasks, where the model definition fits into a file.

## How to use

Copy the `auto_model/` folder into your project's directory, in `.claude/skills/` (or `.agents/skills/` for other providers than Anthropic).

## Phases

The skill is organized into four sequential phases, each with a detailed recipe in `assets/phases/`. The agent will try to skip what has already been done, but the user can also trigger any phase manually by asking the agent to load its recipe.

| Phase | Recipe | Entry signal |
|---|---|---|
| **1 — Setup** | `assets/phases/1_setup.md` | Default starting point |
| **2 — First Model** | `assets/phases/2_first_model.md` | Train/val/test splits exist, or a `model.X` file exists |
| **3 — Iterate** | `assets/phases/3_iterate.md` | `CONTEXT.md` exists in the project root |
| **4 — Finalize** | `assets/phases/4_finalize.md` | User satisfied with validation performance |

Each phase ends with a context dump to `CONTEXT.md` and a history compact, enabling clean resumption.

The agent reads only the YAML frontmatter of a phase file to confirm the right phase before loading the full recipe.

## Skill structure

```
auto_model/
  SKILL.md                  # Skill entry point: phase table, entry signals, how to start
  assets/
    CHECKLIST.md            # Template for progress tracking
    CONTEXT.md              # Template for human-readable updates
    FINAL.md                # Template for final report and test-set evaluation
    phases/
        1_setup.md                # Phase 1: goal, data, metrics, optimization routine
        2_first_model.md          # Phase 2: mock model, sub-agent pipeline test, sanity check
        3_iterate.md              # Phase 3: meta/inner agent loop (core of the skill)
        4_finalize.md             # Phase 4: test-set evaluation, FINAL.md
  references/           # Currently empty, but could include relevant material for your domain
  scripts/
    read_phases.sh        # Bash script to read only the frontmatter of phase files
    read_phases.ps1       # PowerShell script to read only the frontmatter of phase files
```

## License

Licensed under Apache License 2.0. See `LICENSE`.

## Notice

For redistributions and derivative works, preserve applicable notices from `NOTICE` as required by Apache License 2.0.

The use of "*discovered with auto-model*" in any derivative works is kindly encouraged.

## Citation

If you use `auto-model` in your work, please consider citing:

```
@software{auto-model,
  author = {Unlayer AI},
  title = {auto-model: An Agent Skill for Discovering Models from Data},
  year = {2026},
  url = {https://github.com/unlayer-ai/auto-model}
}
```
