function runLassoGridSearch(GCMFileName, FOLD, NUM_RUNS, outputFileName)
    % runLassoGridSearch performs Lasso grid search with cross-validation.
    % Inputs:
    %   - GCMFileName: Name of the GCM data file (assuming it's a structure or cell array).
    %   - FOLD: Number of folds for cross-validation.
    %   - NUM_RUNS: Number of runs.
    %   - outputFileName: Name of the output file for saving results.
    
    % Load the partitions 
    P1=load('Permutation/Partition_Runs250.mat')
    P2=load('Permutation/Partition_Runs251.mat')
    P2.Partitions(:,1:250)=P1.Partitions
    Partitions=P2.Partitions
    clear P1 P2
    
    % Construct the GCM filename
    GCMFilename = [GCMFileName, '.mat'];
    load(GCMFilename)
    % Convert string inputs to numbers
    NUM_RUNS = str2double(NUM_RUNS);
    FOLD = str2double(FOLD);

    % Calculate the critical value for confidence interval
    ci = spm_invNcdf(1 - 0.05);
    EmptyTrainModelEP = zeros(NUM_RUNS, FOLD);  % Initialize a matrix to track empty TrainModelEP

    % Generate a range of lambda values
    lambda_values = 0.0001 * (1.1 .^ (0:99)); % Generates 100 values from 0.0001 to around 12.08%

    % Initialize matrices to store results
    BestCorrelation = zeros(NUM_RUNS, 3);
    MAE = zeros(length(lambda_values), FOLD);
    Correlation = zeros(length(lambda_values), FOLD);

    % Loop over runs
    for run = 1:NUM_RUNS
        % Load target data for the current run
        load(string(strcat('Permutation/Target_Shuffled_run', num2str(run), '.mat')));

        % Get selected partitions for this run
        Selected_Partitions = Partitions{run};
        Steps = 1;

        % Loop over lambda values
        for lambda = lambda_values
            % Loop over folds
            for n = 1:FOLD
                % Training phase
                DcmTrain = GCM(Selected_Partitions.training(n));
                TargetTrain = Target_Shuffled(Selected_Partitions.training(n), :);

                % Load PEB results
                load(sprintf('Permutation/Shuffled_PEB_run%d_fold%d.mat', run, n), 'PEB');

                % Extract relevant PEB information
                TrainEP = abs(full(PEB.Ep));
                TrainEP = reshape(TrainEP, 9, 9, 2);
                TrainEP = TrainEP(:, :, 2);
                TrainEP = TrainEP - diag(diag(TrainEP));

                TrainCP = sqrt(diag(full(PEB.Cp)));
                TrainCP = TrainCP(82:162);
                TrainCP = reshape(TrainCP, 9, 9);

                Inx = TrainEP > (ci * TrainCP);

                % Loop over training models
                TrainModelEP = [];
                for j = 1:length(DcmTrain)
                    % Modify field based on your requirement
                    TmpEP = reshape(DcmTrain{j}.Ep.A .* Inx, 1, []);
                    TmpEP(TmpEP == 0) = [];
                    TrainModelEP(j, :) = TmpEP;
                end
                % Record if TrainModelEP is empty
                if isempty(TrainModelEP)
                EmptyTrainModelEP(run, n) = 1;  % Set the corresponding element to 1
                continue;  % Skip the rest of the loop for this run and fold
                end
                % Train linear regression model with the given lambda
                mdl = fitrlinear(TrainModelEP, TargetTrain, 'Regularization', 'Lasso', 'Lambda', lambda);

                % Testing phase
                DcmTest = GCM(Selected_Partitions.test(n));
                TargetTest = Target_Shuffled(Selected_Partitions.test(n), :);

                % Loop over testing models
                TestModelEP = [];
                for k = 1:length(DcmTest)
                    % Modify field based on your requirement
                    TestTmpEP = reshape(DcmTest{k}.Ep.A .* Inx, 1, []);
                    TestTmpEP(TestTmpEP == 0) = [];
                    TestModelEP(k, :) = TestTmpEP;
                end

                % Predict using the trained model
                Pred_target = predict(mdl, TestModelEP);

                % Calculate and store MAE and correlation
                MAE(Steps, n) = mean(abs(Pred_target - TargetTest));
                Correlation(Steps, n) = corr(Pred_target, TargetTest);
            end
            Steps = Steps + 1;
        end

        % Find the best correlation and corresponding lambda
        [R, P] = max(mean(Correlation, 2, 'omitnan'));
        BestCorrelation(run, 1) = R;
        BestCorrelation(run, 2) = lambda_values(P);

        % Calculate and store mean MAE for the best lambda
        MMAE = mean(MAE, 2);
        BestCorrelation(run, 3) = MMAE(P);
    end

    % Save the results to the specified output file
    save(outputFileName, 'BestCorrelation');
    disp('Hello, All runs are completed!')
end

