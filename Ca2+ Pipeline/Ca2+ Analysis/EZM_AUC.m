p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_cell_filt.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);

% [1:2:13, 17, 20, 24, 27, 30, 32]
%
for i = [1:2:13, 17, 20, 24, 27, 30, 32]
    
    %Load files from server
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    
    %get file names
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
%     
% %     %load selective cells
%        load(fullfile(files(i).folder, 'idx_open.mat'));
%        o=idx;
%        load(fullfile(files(i).folder, 'idx_closed.mat'));
%        p=idx;
% % %     %isolate selective cells
% %zscored_cell_filt= zscored_cell_filt(:,idx);
%  zscored_cell_filt(:,[o p])=[];
%     

    btime = length(timestamp.behavecam);   
    behavior = ones(btime,1);
    
    for ii = 2:3
         behavior = interactions(1000:end,ii);
        [AUC] = get_AUC_approach(5, zscored_cell_filt, timestamp, behavior);
%         [AUC] = get_AUC(5, zscored_cell_filt, timestamp, behavior);
        final_results{i,ii} = mean(AUC);
    end
    
end
