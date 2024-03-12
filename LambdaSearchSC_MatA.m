function LambdaSearchSC(NUM_RUNS, FOLD, GCMDataFile, TargetDataFile, PartitionsDataFile,outputFileName)
    % Initialize variables and data loading
    load(GCMDataFile); % Load GCM data
    load(TargetDataFile); % Load Target data
    load(string(strcat('PEBs/',PartitionsDataFile))); % Load Partitions data
    NUM_RUNS=str2double(NUM_RUNS)
    FOLD=str2double(FOLD)
    % Design hyperparameters
    ci = spm_invNcdf(1 - 0.05);
    Coeff = zeros(NUM_RUNS, FOLD);
    AllInx = zeros(9, 9);

    % Initialize a cell array to store all the models
    %AllModels = cell(NUM_RUNS, FOLD);

    % Initialize lambda values
    lambda_values = 0.0001 * (1.1 .^ (0:99)); % Generates 100 values from 0.0001 to around 12.08

    % Initialize output variables
    BestCorrelation = zeros(NUM_RUNS, 3);

    % Loop over runs
    for run = 1:NUM_RUNS
        c = Partitions{run}; % Load the partition for the current run

        Steps = 1;
        for lambda = lambda_values;
            % Loop over folds
            for n = 1:FOLD
                % Training phase
                DcmTrain = GCM(c.training(n));
                TargetTrain = Target(c.training(n), :);

                % Load PEB results
                load(sprintf('PEBs/PEB_run%d_fold%d.mat', run, n), 'PEB')

                % Extract relevant PEB information
                TrainEP = abs(full(PEB.Ep));
                TrainEP = reshape(TrainEP, 9, 9, 2);
                TrainEP = TrainEP(:, :, 2);
                %TrainEP = TrainEP - diag(diag(TrainEP));

                TrainCP = sqrt(diag(full(PEB.Cp)));
                TrainCP = TrainCP(82:162);
                TrainCP = reshape(TrainCP, 9, 9);

                Inx = TrainEP > (ci * TrainCP);
                AllInx = AllInx + Inx;

                % Loop over training models
                TrainModelEP = [];
                for j = 1:length(DcmTrain)
                    TmpEP = reshape(DcmTrain{j}.Ep.A .* Inx, 1, []);
                    TmpEP(TmpEP == 0) = [];
                    TrainModelEP(j, :) = TmpEP;
                end

                % Train linear regression model with the given lambda
                mdl = fitrlinear(TrainModelEP, TargetTrain, 'Regularization', 'Lasso', 'Lambda', lambda);

                % Store the trained model in the cell array
                % AllModels{Steps, n} = mdl;

                % Count the number of non-zero beta coefficients
                non_zero_coeffs(Steps, n) = sum(mdl.Beta ~= 0);

                % Testing phase
                DcmTest = GCM(c.test(n));
                TargetTest = Target(c.test(n), :);

                % Loop over testing models
                TestModelEP = [];
                for k = 1:length(DcmTest);
                    TestTmpEP = reshape(DcmTest{k}.Ep.A .* Inx, 1, []);
                    TestTmpEP(TestTmpEP == 0) = [];
                    TestModelEP(k, :) = TestTmpEP;
                end

                % Predict using the trained model
                Pred_target = predict(mdl, TestModelEP);

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
    save(outputFileName, 'BestCorrelation','AllInx');
    disp('Hello, All runs are completed!')
end

