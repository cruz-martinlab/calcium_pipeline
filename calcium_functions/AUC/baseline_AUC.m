function [AUC] = baseline_AUC(binsize, ca_data, behavior, timestamp)
%The purpose of this function is to get a baseline read of AUC in 5 second
%intervals. Or however you decide to bin. 
    [msbins, behbins] = ROC_bin(binsize,timestamp);
    [binned_behavior, ~] = ROC_binary_bins(behbins, msbins, behavior, ca_data);
    
    AUC = [];
    for iii = 1:size(ca_data,2)
        auc_temp = [];
        for ii = 2:size(msbins,2)
                g = [msbins(ii-1):msbins(ii)];
                auc = trapz(ca_data(g,iii));
                auc_temp = [auc_temp auc];
        end
         AUC = [AUC mean(auc_temp)];
    end
     
end