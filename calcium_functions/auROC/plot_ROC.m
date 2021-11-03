p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','cell_events_filt.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,7,1);

%parpool(10)
for i = 1:numExps
    
    %Load files from server
    load(fullfile(files(i).folder, 'timestamp.mat'));
   % load(fullfile(files(i).folder, 'cuplocation.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'cell_events_filt.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    
    %Write File Name in Final Results Matrix
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
    
    %if cuplocation(1) == 1;
    %     interactions2 = interactions;
    %     interactions2(:,2) = interactions(:,3);
    %     interactions2(:,3) = interactions(:,2);
    %     interactions = interactions2;
    %elseif cuplocation(2) == 1;
    %        interactions = interactions;
    %end
    
    %bin both the ms and behavior matrices into equal # of frames
    [msbins, behbins] = ROC_bin(100,timestamp);
    
    %Behavior is interactions with Familiar Cup
    behavior = interactions(:,3);
    
    %create values of the matrices based on the bin locations
    [binned_behavior, binned_raw] = ROC_binary_bins(behbins, msbins, behavior, zscored_cell_filt);
    
    %get auROC
    [AUROC, TPR, FPR] = get_ROC(binned_raw, binned_behavior);
    
    %save our original auROC curve values
    auROC_orig = AUROC;
    
    
    
end