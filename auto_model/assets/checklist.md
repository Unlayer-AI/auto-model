# Checklist for model-anything

This checklist mirrors the current workflow in SKILL.md and helps track progress while building an interpretable model from data.

- [ ] Progress tracking is set up by copying this checklist to the project root
- [ ] Goal, scope, intended inputs, intended outputs, and domain language are reviewed with the user
- [ ] Programming language and runtime support are confirmed
- [ ] Existing code, if any, is reviewed for reuse vs. rewrite
- [ ] Data location, availability, permissions, and sufficiency are verified
- [ ] Data cleaning needs are identified and a split strategy is defined
- [ ] Train/validation/test splits are created in the chosen format and stored in the appropriate location
- [ ] Objective/loss function and validation/test metrics are defined with the user
- [ ] Training/evaluation runtime is measured and recorded as a metric
- [ ] A first simple mock model is implemented
- [ ] Code exists to train the model, generate predictions, and log metrics
- [ ] The mock model is tested end to end
- [ ] A basic parameter optimization routine is implemented or selected from a library
- [ ] Main project choices are written to `PREAMBLE.md`
- [ ] Conversation and working context are compacted after saving the main project information
- [ ] Iterative model-improvement loop is planned with meta-iterations, sub-agents, and inner iterations
- [ ] Intermediate plans and evaluations are saved under the relevant `meta_*` folders
- [ ] Progress summaries are written after each meta-iteration
- [ ] Results are reviewed with the user after the planned iterations
- [ ] Training and validation performance plots are prepared for review
- [ ] Final test-set evaluation is performed once the user is satisfied with validation performance
- [ ] A final `FINAL.md` file is created summarizing the final model performance and main changes that led to improvements