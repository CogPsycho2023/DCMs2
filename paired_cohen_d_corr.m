function cohen_d = paired_cohen_d_corr(r1, r2)
    % Calculate paired Cohen's d for two groups of prediction correlation coefficients
    
    % Fisher's Z transformation for each group
    z1 = atanh(r1);
    z2 = atanh(r2);
    
    % Difference in transformed correlations
    diff_z = z1 - z2;
    
    % Standard deviation of the differences
    sd_diff = std(diff_z);
    
    % Cohen's d for paired data
    cohen_d = mean(diff_z) / sd_diff;
end