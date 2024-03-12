function NonShuffled_10_FOLD_PEBs(StartingRun, Runs,GCM,Target,Cov, Mat)

    TargetFilename = [Target,'.mat'];
    GCMFilename = [GCM, '.mat'];
    
    load(GCMFilename); % Load the GCM matrix from the provided filename
    load(TargetFilename); % Load the Target matrix from the provided filename

    % Create the "PEBs" directory if it doesn't exist
    if ~exist('PEBs', 'dir')
        mkdir('PEBs');
    end
    
    for run = str2double(StartingRun):(str2double(StartingRun) + str2double(Runs) - 1)
        rng(run); % Set the random number generator seed based on the run number
        %start to split%
        c = cvpartition(length(GCM), 'KFold', 10);
        Partitions{run} = c;
    
        for n = 1:10
            % Training phase
            DcmTrain = GCM(c.training(n));
            TargetTrain = Target(c.training(n), :);

            M.X = [ones(size(TargetTrain, 1), 1), TargetTrain - mean(TargetTrain)];
            M.Xnames = {'GM', Cov};
            PEB = spm_dcm_peb(DcmTrain, M, Mat);
        
            % Save the PEB for the current run and fold
            save(sprintf('PEBs/PEB_run%d_fold%d.mat', run, n), 'PEB');
        end
    end
    save(sprintf('PEBs/Partition_Runs%d.mat', str2double(Runs)),'Partitions')
    disp('Hello, All runs are completed!')
end
