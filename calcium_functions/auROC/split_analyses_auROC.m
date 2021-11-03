p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','cell_events_filt.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,1,1);

parpool(10)
for i = 1:numExps
    
    %Load files from server
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'cuplocation.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'cell_events_filt.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    
    %Write File Name in Final Results Matrix
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
    
    %get our split indices for analysis
    behavesplit = round(size(interactions,1)/2);
    behave_length = size(interactions,1);
    msplit = round(size(zscored_cell_filt,1)/2);
    ms_size = size(zscored_cell_filt,1);
    
    %timestamp for analysis of first half
    timestamp1 =  timestamp;
    timestamp1.behavecam = timestamp1.behavecam(1:behavesplit,:);
    timestamp1.mscam = timestamp1.mscam(1:msplit,:);
    %timestamp for second half
    timestamp2 = timestamp;
    timestamp2.behavecam = timestamp2.behavecam(behavesplit:behave_length,:);
    timestamp2.mscam = timestamp2.mscam(msplit:ms_size,:);
    
    %prepare ca2+ data 
    zscore = zscored_cell_filt(1:msplit,:);
    
    if cuplocation(1) == 1;
        interactions2 = interactions;
        interactions2(:,2) = interactions(:,3);
        interactions2(:,3) = interactions(:,2);
        interactions = interactions2;
    elseif cuplocation(2) == 1;
        interactions = interactions;
    end
    
    %bin both the ms and behavior matrices into equal # of frames
    [msbins, behbins] = ROC_bin(100,timestamp1);
    
    %Behavior is interactions with Familiar Cup
    behavior = interactions(1:behavesplit,2);
    
    %create values of the matrices based on the bin locations
    [binned_behavior, binned_raw] = ROC_binary_bins(behbins, msbins, behavior, zscore);
    
    %get auROC
    [AUROC, TPR, FPR] = get_ROC(binned_raw, binned_behavior);
    
    %save our original auROC curve values
    auROC_orig = AUROC;
    
    %TPR_orig = TPR;
    %FPR_orig = FPR;
    %create an empty matrix for shuffled data
    shuffled_raw = zeros(1000,size(binned_raw,2));
    
    %shuffle the data 1000 times (circular shift)
    
    p = randperm(size(binned_raw,1),1000);
    parfor ii = 1:1000
        binned_raw_shift = circshift(binned_raw,p(ii),1);
        [AUROC, TPR, FPR] = get_ROC(binned_raw_shift, binned_behavior);
        shuffled_raw(ii,:) = AUROC;
    end
        
    %create 2std threshold
    stdthresh = quantile(shuffled_raw,0.95);
    %find cells whos original auROC is 2std greater than mean shuffled
    %auROC
    selective = auROC_orig > stdthresh;
    %get cell numbers
    idx = find(selective == 1);
    %get percentage
    percent_sel = length(idx)/size(selective,2);
     
    %save cell numbers and percentage
    final_results{i,2} = idx;
    final_results{i,3} = percent_sel*100;
    
    
    idx_cells = zscored_cell_filt(msplit:ms_size,idx);
    count = 3;
    for ii = [2,3]
        count = count + 1;
        if ii < 9
            behavior = interactions((behavesplit:behave_length),ii);
            [AUC] = get_AUC_approach(5, idx_cells, timestamp2, behavior);
            final_results{i,count} = mean(AUC);
        else 
            %[AUC] = baseline_AUC(5000, idx_cells, behavior, timestamp2);
            %final_results{i,count} = mean(AUC);
        end
    end

end


delete(gcp('nocreate'))