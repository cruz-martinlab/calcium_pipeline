function [AUC, TPR, FPR] = get_ROC(binned_raw, binned_behavior)

%Connor Johnson 8/5/2020 ACM Lab BU
%
%The purpose of this code is to extract the area under ROC curves using 
%zscored df/f calcium traces to predict behavior
%
%Outputs:
%AUC = area under ROC curve
%TPR = matrix of all TPR values calculated from different thresholds
%FPR = matrix of all FPR values calculated from different thresholds
%
%TPR and FPR are saved as outputs in case we want to plot some of our ROC
%curves, but if that is not the case they can be omitted in main script

    
    AUC = zeros(1,size(binned_raw,2));
    
    %for loop to go through each cell
    for ii = 1:size(binned_raw,2)
        %create threshold based on max zscore of cell
        max_zscore = max(binned_raw(:,ii));
        min_zscore = min(binned_raw(:,ii));
        thresholds = [min_zscore:0.5:max_zscore,max_zscore];
        %create holding variable for TPR and FPR
        TPR = zeros(1,size(thresholds,2));
        %TPR(1) = 1;
        FPR = zeros(1,size(thresholds,2));
        %FPR(1) = 1;
        %for loop to go through each threshold
        for iii = 1:size(thresholds,2)
            %make binned data binary based on threshdold
            thresh_raw = double(binned_raw > thresholds(iii));
            
            %create 'confusion matrix'
            true_pos = find(binned_behavior & thresh_raw(:,ii)' == 1);
            false_pos = find(binned_behavior == 0 & thresh_raw(:,ii)' == 1);
            true_neg = find(thresh_raw(:,ii)' == 0 & binned_behavior == 0);
            false_neg = find(thresh_raw(:,ii)' == 0 & binned_behavior == 1);
            
            
            %Calculate TPR and FPR
            TPR(iii) = (size(true_pos,2)/(size(true_pos,2)+size(false_neg,2)));
            FPR(iii) = (size(false_pos,2)/(size(false_pos,2)+size(true_neg,2)));
           
        end
        %if ii == 79 || ii == 84
        %hold on
        %plot(FPR,TPR)
        %end
      
        %Calculate auROC for that cell (non-shuffled data)
        AUC(ii) = trapz(fliplr(FPR),fliplr(TPR));

    end           


end