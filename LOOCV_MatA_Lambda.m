function trainAndTestLinearModel(TargetData, GCMData, outputFileName)
    
    % Initialize variables and data loading
    load(GCMData); % Load GCM data
    load(TargetData); % Load Target data
    
    % Design hyperparameters
    ci = spm_invNcdf(1 - 0.05);
    % Initialize lambda values
    lambda_values = 0.0001 * (1.1 .^ (0:99)); % Generates 100 values from 0.0001 to around 12.08

    % Initialize output variables
    BestCorrelation = zeros(numel(GCM), 3);
    Ns = numel(GCM);    
    
    Steps = 1
    
    for lambda = lambda_values
        
    
        for i = 1:Ns
        
            % Remove one subject
        
            j = 1:Ns;
        
            j(i) = [];
        
            GCMSubset = GCM(j);
        
            X = Target(j);

            peb = sprintf('PEB_%d.mat', i);
        
            load(peb)
  
            TEP = abs(full(PEB.Ep));
        
            TEP = reshape(TEP(:, 2), 9, 9);
        
            TCP =  sqrt(diag(PEB.Cp));
        
            TCP = reshape(TCP(82:162), 9, 9);
        
            TEP = TEP - diag(diag(TEP));
       
            Inx = TEP > (ci * TCP);

            TMP = [];
            
            Ep=[]

            for K = 1:length(GCMSubset)
            
                TMP = reshape(GCMSubset{K}.Ep.A .* Inx, [], 1);
            
                TMP(TMP == 0) = [];
            
                Ep(K, :) = TMP';
        
            end
            
            
            mdl = fitrlinear(Ep, X, 'Regularization', 'Lasso','Lambda', lambda);
            
            dcm = GCM{i};
            
            EP_test=[];
            
            EP_test = reshape(dcm.Ep.A .* Inx, [], 1);
        
            EP_test(EP_test == 0) = [];

            qE(i,:) = predict(mdl, EP_test');
    
        end

        BestCorrelation(Steps,1) = corr(qE, Target);
        BestCorrelation(Steps,3) = mean(abs(qE - Target)); % Calculate MAE directly
        BestCorrelation(Steps,2) = lambda
        Steps  = Steps + 1
    end
    save(outputFileName, 'BestCorrelation');
    disp('Hello, All runs are completed!')
end
