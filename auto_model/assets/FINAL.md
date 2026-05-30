# <Project name> — final model report

> Created in Phase 4 — Finalize. Summarizes the final model, metrics, and key findings.

---

## Model
- **File:** `<path/to/final/model.X>`
- **Form:** <full description of the functional form — equations if concise, or reference the file>
- **Fitted parameters:** <list with values and units, e.g. "amplitude a = 0.82 (dimensionless), width w = 0.14 m/s">
- **Dependencies:** <external libraries or fixed code components the model relies on>

---

## Performance

| Split | <Loss/Cost/Objective> | <Metric 2> | <Metric 3> | Runtime | Memory |
|---|---|---|---|---|---|
| Training | <value> | … | … | <s> | <MB> |
| Validation | <value> | … | … | <s> | <MB> |
| **Test** | **<value>** | **…** | **…** | <s> | <MB> |

---

## Structural evolution

| Step | Change | val_loss |
|---|---|---|
| Mock model | <initial form, e.g. "constant μ = 0.8"> | <baseline value> |
| <Change 1> | <what changed and why it was tried, e.g. "added velocity-dependent decay term"> | <value or Δ> |
| <Change 2> | … | … |
| **Final model** | **<final form>** | **<value>** |

**Summary:** <2–4 sentences on what drove improvements, what was tried and didn't help, and why
the search was stopped here.>

---

## Caveats and limitations
- <Limitation 1, e.g. "model assumes the functional form is separable in v and Fz; a joint (v, Fz) form may fit low-load data better">
- <Limitation 2, e.g. "test set covers the same operating range as training — extrapolation behavior is untested">
- <Limitation 3 if any>

## Suggested next steps
- <Follow-up 1, e.g. "relax fixed component X and refit jointly">
- <Follow-up 2, e.g. "collect data in region Y where residuals are largest">
- <Follow-up 3 if any>
