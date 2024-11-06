# DCMs2
The code for task-evoked modulatory and intrinsic EC prediction
This README describes the steps in our Effective Connectivity (EC) prediction analysis, including Lasso-regularized linear regression, label-shuffled permutation testing, and sensitivity analyses. The analysis consists of four main stages, with scripts organized accordingly.

#Step 1: EC Prediction with PEB
Script: runPEB.m
Description: This script generates 5-fold data splits and performs Parametric Empirical Bayes (PEB) modeling for each fold to predict EC features.

#Step 2: Lasso-Regularized Linear Regression
Scripts: LambdaSearchPEB_MatB.m / LambdaSearchPEB_MatA.m
Description: These scripts implement Lasso-regularized linear regression with a lambda search to optimize the regularization parameter.

#Step 3: Label-Shuffled Permutation for k-Fold PEB
Script: runPEBWithShuffling.m
Description: This script conducts label-shuffled k-fold PEB analyses to test the robustness of our EC predictions. The process includes 500 permutations, split into two sets of 250 to manage computational limits (24-hour runtime).

#Step 4: Permutation Testing with Lasso lambda Search
Scripts: runLassoGridSearch_MatB.m / runLassoGridSearch_MatA.m
Description: These scripts perform permutation-based prediction with lambda searching, further validating the stability of EC predictions.

#Sensitivity Analyses
Additional analyses explore alternative methods, including:

10-Fold Cross-Validation: Script: NonShuffled_10_FOLD_PEBs.m, runLOOCVPEB.m
Leave-One-Out Cross-Validation (LOOCV)
Bootstrap Model Reweighting (BMR)
Ridge Regression
