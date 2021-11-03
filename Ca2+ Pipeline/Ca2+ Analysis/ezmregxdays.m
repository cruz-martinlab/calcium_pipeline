p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\registration\ezm_ezmplat');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_cell.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);


for i = 1:2:numExps
    
    %Load files from server
    load(fullfile(files(i).folder, 'timestamp.mat'));
     load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'cell_events.mat'));
    %load(fullfile(files(i).folder, 'startframe.mat'));
    load(fullfile(files(i).folder, 'zscored_cell.mat'));
        file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
%     %load selective cells
    load(fullfile(files(i).folder, 'idx_closed.mat'));
     btime = length(timestamp.behavecam);
   behavior = ones(btime,1);
    %isolate selective cells
  %interactions = ones(size(interactions));
%   
%     zscored_cell(:,[h k]) = [];
zscored_cell_filt = zscored_cell(:,idx);
%     %cell_events=cell_events(:,idx);

    
    count = 1;
    for ii = [2,3]
        count = count+1;
        
       % behavior = interactions(:,ii);
        [AUC] = get_AUC_approach(5, zscored_cell_filt, timestamp, behavior);
        final_results{i,count} = mean(AUC);
    end
        %Load files from server
    load(fullfile(files(i+1).folder, 'timestamp.mat'));
     load(fullfile(files(i+1).folder, 'obj_interactions.mat'));
    load(fullfile(files(i+1).folder, 'cell_events.mat'));
    %load(fullfile(files(i).folder, 'startframe.mat'));
    load(fullfile(files(i+1).folder, 'zscored_cell.mat'));
        file_delim = strsplit(files(i+1).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i+1,1) = currentfile;

%     %load selective cells
    load(fullfile(files(i).folder, 'idx_closed.mat'));
    %behavior = ones(btime,1);
    %isolate selective cells
  %interactions = ones(size(interactions));
%   
%     zscored_cell(:,[h k]) = [];
zscored_cell_filt = zscored_cell(:,idx);
%     %cell_events=cell_events(:,idx);
   btime = length(timestamp.behavecam);
   behavior = ones(btime,1);
    
    count = 1;
    for ii = [2,3]
        count = count+1;
        
        %behavior = interactions(:,ii);
        [AUC] = get_AUC_approach(5, zscored_cell_filt, timestamp, behavior);
        final_results{i+1,count} = mean(AUC);
    end
    
end
