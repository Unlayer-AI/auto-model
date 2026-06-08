# <Project name> — final model report

> Concise handoff for the selected model. See `CONTEXT.md` for the full experiment history.

---

## Outcome
- **Decision:** <accept final model / return to iteration / do not use>
- **Goal:** <one-sentence modeling goal>
- **Result:** <one-to-three sentences stating whether the goal and key constraints were met>

## Selected model
- **File:** `<path/to/final/model.X>`
- **Form:** <concise description of the model structure; reference the file for details>
- **Why selected:** <best validation result, best trade-off, or other decision criterion>
- **Usage:** <entry point or command, expected inputs/outputs, and required preprocessing>

---

## Final evaluation

| Split | <Loss/Cost/Objective> | <Metric 2> | <Metric 3> | Runtime | Memory |
|---|---|---|---|---|---|
| Baseline validation | <value> | … | … | <s> | <MB> |
| Final validation | <value> | … | … | <s> | <MB> |
| **Final test** | **<value>** | **…** | **…** | <s> | <MB> |

| Acceptance criterion | Target | Result | Status |
|---|---|---|---|
| <Primary metric or constraint> | <target> | <result> | <Pass / Fail> |
| <Additional constraint> | <target> | <result> | <Pass / Fail> |

- **Generalization:** <brief interpretation of the validation-to-test difference>
- **Key improvement over baseline:** <most important structural change and measured improvement>

---

## Limitations and next steps
- <Most important limitation or untested assumption>
- <Most useful follow-up, if any>

