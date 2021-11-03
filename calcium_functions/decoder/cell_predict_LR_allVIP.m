p_folder = uigetdir('D:\Users\Connor Johnson\Desktop\ACC Figures\goodhill_lab_data\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','raw_trace.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);
tic
for i = [1:numExps]
    
    load(fullfile(files(i).folder, 'binned_zscore.mat'));
    load(fullfile(files(i).folder, 'binned_behavior.mat'));
    
    

    behavior = binned_behavior';
    zscored_cell_filt = binned_zscore;
    

    file_delim = strsplit(files(i).folder, '\');
    x = 'Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\';
    currentfile = join(file_delim(7:10),'\');
    curr = strcat(x,char(currentfile));
    final_results(i,1) = currentfile;

        
    
     %for ROC indices
%     load(fullfile(curr, 'idx_empty.mat'));
%     idx_openROC = idx;
    load(fullfile(curr, 'idx_littermate.mat'));
    idx_closedROC = idx;

% 
%     %for LR indices   
%     load(fullfile(files(i).folder, 'idx_empty.mat'));
%     idx_openROC = idx;
%     load(fullfile(files(i).folder, 'idx_littermate.mat'));
%     idx_closedROC = idx;
    
    zscored_cell_filt = zscored_cell_filt(:,[idx_closedROC]);
    %zscored_cell_filt(:,[idx_closedROC idx_openROC]) = [];
    pred_addcells = zeros(size(zscored_cell_filt,2),1000);
    
    %go through and assess cell by cell    
    for ii = 1:size(zscored_cell_filt,2)
       %temp variable for when we are doing 100 loops
        pred_temp = zeros(1000,1);
        %assess the cell 1000 times using 70% of data to train
        for iii = [1:1000]
            
            %get random cell index based on number of cells we want to eval
            rand_cells = randperm(size(zscored_cell_filt,2),ii);
            %run 70-30 function
            [Y_70, Y_30, X_70, X_30] = split_data_70_30(zscored_cell_filt(:,rand_cells), behavior);

            %run LR
            [B,DEV,STATS] = mnrfit(X_70,Y_70);
            
            phat = mnrval(B,X_30);
            pred_open = phat(:,1) < 0.5;
            pred_temp(iii) = mean((pred_open + 1) == Y_30);
        end
        pred_addcells(ii,:) = pred_temp;
    end
    
    save(fullfile(files(i).folder, 'pred_addcells_lit.mat'),'pred_addcells');
end
toc