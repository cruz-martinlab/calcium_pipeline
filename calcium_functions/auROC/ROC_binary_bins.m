function [binned_behavior, binned_raw] = ROC_binary_bins(behbins, msbins, behavior, zscored_cell_filt)

%Connor Johnson 8/3/2020 ACM Lab BU
%The purpose of this function is fill in the binned miniscope and behavior
%matrices with values that can be used to calculate ROC curves.
%
%Inputs:
%
%behbins = indices of my binned behavior
%msbins = indicices of my binned miniscope data
%behavior = original binary matrix for a single behavior
%zscored_cell_filt = zscored df/f trace from Jessica's code
%
%Outputs:
%
%binned_behavior = binned binary behavior matrix
%binned_raw = binned zscored df/f traces from each cell
%%

    %create empty matrix for binned behavior
    binned_behavior = zeros(size(behbins));
    
    for i = 2:size(behbins,2)
        %sum the binary values within one bin
        bin = behbins(i-1):behbins(i);
        %number of frames that make up half of the bin
        half_frames = (size(bin,2)/2);
        %If the behavior occured for more than half of the bins length,
        %that bin is given a binary value of 1
        if sum(behavior(bin)) > half_frames
            binned_behavior(i) = 1;
        else
            binned_behavior(i) = 0;
        end
    end
    
    %create empty bin for zscored data
    binned_raw = zeros(size(msbins,2),size(zscored_cell_filt,2));
    
    for i = 1:size(zscored_cell_filt,2)
        %make first values the same
        binned_raw(i,1) = zscored_cell_filt(1,i);
        for ii = 2:size(msbins,2)
            %find all zscored raw trace values within bin
            bin = msbins(ii-1):msbins(ii);
            %bin value is average of all values within bin
            binned_raw(ii,i) = mean(zscored_cell_filt(bin,i));
        end
    end


end