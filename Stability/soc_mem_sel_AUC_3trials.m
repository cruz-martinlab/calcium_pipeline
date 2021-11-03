p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','idx_obj1.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);

% [1:2:13,18,22,30,34,38]
for i =[1:4:numExps]
    
    %Load files from server
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'zscored_cell.mat'));
    
    %get file names
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
    
    %load selective cells
     load(fullfile(files(i).folder, 'idx_obj1.mat'));
idx_open = idx;
%     load(fullfile(files(i).folder, 'idx_empty.mat'));
%  idx_closed = idx;
%   x = [idx_open idx_closed];
% x=idx;
    %isolate selective cells
       zscored_cell_filt = zscored_cell(:,idx);
%      zscored_cell_filt(:,x) =[];

    btime = length(timestamp.behavecam);   
    behavior = ones(btime,1);
    
    for ii = 2:3
%          behavior=interactions(:,ii);
        [AUC] = get_AUC_approach(5, zscored_cell_filt, timestamp, behavior);
        final_results{i,ii} = mean(AUC);
    end
        load(fullfile(files(i+1).folder, 'timestamp.mat'));
    load(fullfile(files(i+1).folder, 'obj_interactions.mat'));
    load(fullfile(files(i+1).folder, 'zscored_cell.mat'));
       
     zscored_cell_filt = zscored_cell(:,idx);
%     zscored_cell_filt(:,x) =[];
% 
%      zscored_cell_filt = zscored_cell(:,x);
             btime = length(timestamp.behavecam);   
    behavior = ones(btime,1);
    for ii = 2:3
%          behavior=interactions(:,ii);
        [AUC] = get_AUC_approach(5, zscored_cell_filt, timestamp, behavior);
        final_results{i,ii+2} = mean(AUC);
    end
    
            load(fullfile(files(i+2).folder, 'timestamp.mat'));
    load(fullfile(files(i+2).folder, 'obj_interactions.mat'));
    load(fullfile(files(i+2).folder, 'zscored_cell.mat'));
       
     zscored_cell_filt = zscored_cell(:,idx);
%     zscored_cell_filt(:,x) =[];
% 
%      zscored_cell_filt = zscored_cell(:,x);
             btime = length(timestamp.behavecam);   
    behavior = ones(btime,1);
    for ii = 2:3
%          behavior=interactions(:,ii);
        [AUC] = get_AUC_approach(5, zscored_cell_filt, timestamp, behavior);
        final_results{i,ii+4} = mean(AUC);
    end
end
