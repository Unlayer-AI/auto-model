---
name: auto-model
description: Guides the user in creating an interpretable, mathematical model out of data (e.g. from logistic or survival regression to PDEs for physical systems - not neural networks or other black-box machine learning methods). Use when user asks for help in creating or improving an existing model. Uses an iterative meta/inner agent loop to explore structural model modifications in parallel.
license: CC-BY-4.0
---

# auto-model
A structured guide to building interpretable, mechanistic models from data with agents. To apply to a wide range of tasks, from simple regression to complex physical systems, from automotive to pharmacology.

---

## How to proceed

1. META: Keep track of progress. Make a copy of `assets/checklist.md` to the root of the project; update the checklist as you complete each step. If checklist with partial progress is already present in the root of the project, then ask the user whether to resume from where you left off.

2. GOAL: Review with the user the context, intended goal and scope of the model. Further check with programming language/software should be used, whether the runtime supports it and libraries are installed. In the following, use the lingo appropriate to the user's context (e.g. loss function vs. cost function / features vs. covariates / training vs. calibration).

3. SKIP?: If code already exists that realizes (some of) the steps below, skip to the relevant step(s) and review with the user whether to reuse existing code or rewrite from scratch. Use these signals to decide where to skip to: if train/val/test split files exist → skip to step 5; if a `model.X` file exists → skip to step 8; if `CONTEXT.md` exists → skip to step 9.

4. DATA: Identify where/which is the data to fit/calibrate, validate, and test the model; which are the intended input and output variables of the model; whether these are present and sufficient; whether data needs cleaning; finally define a reasonable data split strategy that ideally results in `train.X`, `validation.X`, and `test.X` (where `X` is the appropriate extension e.g. `.csv` or `.mat` or `.rdata`) stored in an appropriate location.

5. METRICS: Define with the user the objective/loss function to train/calibrate the model and intended metrics to evaluate the model performance on the validation and test sets. Make sure that *run-time* and *memory usage* to train and evaluate the model is one of the metrics.

6. PARAMETER CALIBRATION/OPTIMIZATION: Implement a basic parameter optimization routine e.g. using gradient descent or a black-box optimization method (e.g. PSO) to fit/calibrate the model parameters to the training data. Propose to the user using libraries over implementing from scratch.

7. FIRST MODEL: Program a first, really simple mock model in a `model.X` file (`X` being the appropriate extension e.g. `.py` or `.m` or `.r`) and code, in (a) different file(s), to train and evaluate the model. Test that this works end-to-end (e.g. on small subset of data it fits to the train data and validates): code exists to train it, obtain predictions, and log metrics. *important*: use a sub-agent to test the model, because we need to ensure that sub-agents can read/write the files and run the code without issues before we get to the iterative improvement phase. *note*: a trick to make it easier for the optimization routine to call the model with different parameter values, is to make the parameters be an input argument to the model's function call that is set to a reasonable default value in case they are not specified.

8. SANITY CHECK: Verify the mock model produces plausible outputs and that the optimization problem is well-posed. If the model fails to converge, data is too sparse, or metrics are degenerate, surface a diagnosis to the user before proceeding. 

9. STORE INFO: Dump main info about goal, data, variables, metric and other choices in a `CONTEXT.md` file in the root of the project. If you arrived here by skipping and some things are unclear, ask the user. This will be useful to keep track of the main choices and assumptions, and to share with others. Then, *compact your conversation history to free memory*. 

10. ITERATIVE MODEL IMPROVEMENT - SETUP: You'll now orchestrate the model improvement process. There is a "meta" loop where you take charge, and an inner loop where sub-agents make and evaluate model changes. In the meta loop, you review overall progress *without user involvement* and decide how to instruct the sub-agents for the next meta iteration. In the inner loop, sub-agents attempt to improve the model.
Use the run-time (times the parameter optimization steps) and memory usage of the mock model to estimate how long the whole process will take (consider sub-agents work in parallel, and that sub-agents thinking and writing will also take a few seconds each time), to then guide the user in choosing how many meta-iterations M, no. sub-agents S, and inner-iterations I they wish to run. 

11. ITERATIVE MODEL IMPROVEMENT - EXECUTION:
For M meta-iterations:
Spawn S sub-agents. Ensure each sub-agent writes only within its own `meta_m/agent_s/` directory to avoid conflicts during parallel execution. Task each sub-agent to, for I sequential iterations:
  - plan a *structural* (e.g. at level of equations or code functions) modifications to the model and store in `meta_m/agent_s/attempt_i/plan.md` *based on its previous attempt's evaluation results*;
  - modify a copy of the `model.X` file to store in `meta_m/agent_s/attempt_i/model.X`;
  - trains/calibrates/optimizes the model on the training set using the optimization routine (step 8) and store the training metrics and optimal parameters in `meta_m/agent_s/attempt_i/training.md`;
  - evaluate the proposed model (on training and validation sets) and store results in `meta_m/agent_s/attempt_i/evaluation.md`;
  - move on to next iteration.
Once the iterations are done, review the final proposed models of each agent with their plans and evaluation results. Think of what is working and what is not. Formulate new hypotheses to progress the search, preparing the prompt to feed to the sub-agents of the next iteration so that their search efforts won't overlap. Add a summary of the overall progress and next steps to `CONTEXT.md` (e.g. a summary of the key findings and hypotheses for the next meta iteration). Proceed with the next meta-iteration.

12. REVIEW WITH USER: Once the M meta-iterations are terminated, review the progress with the user. Include plots of the training and validation performance of the best-over-iterations found models, and a discussion of the main changes that led to improvements. Ask the user whether they want to further iterate (go back to step 10) or whether they want to finalize the best-found model and move on to testing. If a new set of iterations is started, consider *compacting your conversation history* to keep your memory lean. Ensure that your new meta iterations do not start from 0 but from M+1 (or what applies) - to avoid overwriting previous logs.

13. FINAL TESTING: Once the user is satisfied with the best-found model performance on the validation set, evaluate the final model on the test set and report results. Consider whether to further iterate to improve test performance, or whether to finalize and move on to documentation and sharing. If final, create a `FINAL.md` file in the root of the project summarizing the final model performance and the main changes that led to improvements.
