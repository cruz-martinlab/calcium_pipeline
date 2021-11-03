p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','idx_novel.mat'));
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,3,1);

for i = 1:numExps
    
    %load files needed for this script
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'cuplocation.mat'));
    load(fullfile(files(i).folder, 'idx_novel.mat'));
    littermate = idx;
   % load(fullfile(files(i).folder, 'idx_novel.mat'));
    empty = idx;
    
    %UNCOMMENT FOR NOVEL
    %zscored_cell_filt(:,[empty,littermate]) = [];
    
    %load selective cells
    zscored_cell_filt = zscored_cell_filt(:,idx);
     
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
   
    if cuplocation(1) == 1;
         interactions2 = interactions;
         interactions2(:,2) = interactions(:,3);
         interactions2(:,3) = interactions(:,2);
         interactions = interactions2;
    elseif cuplocation(2) == 1;
         interactions = interactions;
    end

    for ii = 2:3
        behavior = interactions(:,ii);
        %AUC for t0->(t0+t)
        AUC = get_AUC(5,zscored_cell_filt,timestamp,behavior);
        %AUC = get_AUC_neg(5,zscored_cell_filt,timestamp,behavior);
        final_results{i,ii} = mean(AUC);
    end
    
end