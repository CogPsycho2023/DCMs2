function runPEBLOOCV(GCM, Target, Cov, Mat)

    TargetFilename = [Target, '.mat'];
    GCMFilename = [GCM, '.mat'];
    
    load(GCMFilename); % Load the GCM matrix from the provided filename
    load(TargetFilename); % Load the Target matrix from the provided filename

    % Loop over each data point for LOOCV
    numDataPoints = length(GCM);
    for n = 1:numDataPoints
        % Define training and test sets
        DcmTrain = GCM([1:n-1, n+1:end]); % All except the nth element
        TargetTrain = Target([1:n-1, n+1:end], :); % All except the nth element

        % Set up the model matrix
        M.X = [ones(size(TargetTrain, 1), 1), TargetTrain - mean(TargetTrain)];
        M.Xnames = {'GM', Cov};

        % Perform PEB analysis
        PEB = spm_dcm_peb(DcmTrain, M, Mat);

        % Save the PEB result for the current LOOCV fold
        save(sprintf('PEB_%d.mat', n), 'PEB');
    end

    disp('Hello, LOOCV folds are completed!');
end
