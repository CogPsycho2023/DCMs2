This repository contains code for task-evoked modulatory and intrinsic Effective Connectivity (EC) prediction. Our analysis consists of four primary steps, using Lasso-regularized linear regression, label-shuffled permutation testing, and various sensitivity analyses. Each step has dedicated scripts for efficient and organized execution.

**Step 1: EC Prediction with Parametric Empirical Bayes (PEB)**
Script: runPEB.m
Description: Generates 5-fold data splits and applies Parametric Empirical Bayes (PEB) modeling to predict EC features for each fold.

**Step 2: Lasso-Regularized Linear Regression with Lambda Search**
Scripts: LambdaSearchPEB_MatB.m, LambdaSearchPEB_MatA.m
Description: Executes Lasso-regularized linear regression with a lambda search, optimizing the regularization parameter to improve prediction accuracy.

**Step 3: Label-Shuffled Permutation Testing for k-Fold PEB**
Script: runPEBWithShuffling.m
Description: Conducts label-shuffled k-fold PEB analyses to test the robustness of EC predictions. The script performs 500 permutations (split into two sets of 250) to accommodate computational limits (24-hour runtime).

**Step 4: Permutation Testing with Lasso Lambda Search**
Scripts: runLassoGridSearch_MatB.m, runLassoGridSearch_MatA.m
Description: Uses permutation-based prediction with lambda searching to further validate EC prediction stability.
Sensitivity Analyses
These additional analyses examine alternative cross-validation schemes, prediction algorithms, and models.

**Cross-Validation Variants**
Scripts: NonShuffled_10_FOLD_PEBs.m, runPEBLOOCV.m
Description: Applies different cross-validation schemes (e.g., 10-fold and Leave-One-Out Cross-Validation (LOOCV)) to assess prediction stability.
Ridge-regularized Linear Regression

**Prediction algorithm**
Scripts: LambdaSearchPEB_MatB_Ridge.m, LambdaSearchPEB_MatA_Ridge.m
Description: Estimates prediction correlations using ridge-regularized linear regression as an alternative to Lasso.

**Bayesian Model Reduction (BMR)**
Scripts: BMR, LambdaSearchBMA_MatA.m, LambdaSearchBMA_MatB.m
Description: To overcome server usage limits, we recompiled MATLAB using the MATLAB runtime (v98) and conducted Bayesian Model Reduction (BMR) to estimate prediction correlations based on BMR-derived features.
