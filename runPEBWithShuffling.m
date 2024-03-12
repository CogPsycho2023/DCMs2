function runPEBWithShuffling(StartingRun, Permutation_Runs, Cov, Mat, GCMFileName, TargetFilename)

    GCMFilename = [GCMFileName, '.mat'];
    
    % Load the GCM matrix from the provided filename
    load(GCMFilename);

    % Load the Target matrix from the provided filename
    load(TargetFilename);

    % Create a "Permutation" directory to save all output files
    permutationFolder = 'Permutation';
    if ~exist(permutationFolder, 'dir')
        mkdir(permutationFolder);
    end

    for run = str2double(StartingRun):(str2double(StartingRun) + str2double(Permutation_Runs) - 1)
        rng(run); % Set the random number generator seed based on the run number
        Target_Shuffled = Target(randperm(size(Target, 1)), :);
   
        c = cvpartition(length(GCM), 'KFold', 5);
        Partitions{run} = c;
    
        for n = 1:5
            % Training phase
            DcmTrain = GCM(c.training(n));
            TargetTrain = Target_Shuffled(c.training(n), :);

            M.X = [ones(size(TargetTrain, 1), 1), TargetTrain - mean(TargetTrain)];
            M.Xnames = {'GM', Cov};
            PEB = spm_dcm_peb(DcmTrain, M, Mat);
        
            % Save the PEB for the current run and fold in the "Permutation" folder
            save(fullfile(permutationFolder, sprintf('Shuffled_PEB_run%d_fold%d.mat', run, n)), 'PEB');
        end
        % Save the shuffled Target for each run in the "Permutation" folder
        save(fullfile(permutationFolder, sprintf('Target_Shuffled_run%d.mat', run)), 'Target_Shuffled');
    end
    save(fullfile(permutationFolder, sprintf('Partition_Runs%d.mat', str2double(Permutation_Runs))), 'Partitions')
    disp('Hello, All runs are completed!')
end

