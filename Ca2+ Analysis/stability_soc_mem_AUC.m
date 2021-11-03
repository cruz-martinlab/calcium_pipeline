p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\registration');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_cell.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);
count=0;
for iii = 1:4:numExps
    count=count+1;
    count2= 0;
%         load(fullfile(files(iii).folder, 'idx_mouse1.mat'));
for i = iii:iii+3
    count2=count2+1;
    %Load files from server
    load(fullfile(files(i).folder, 'timestamp.mat'));
     load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'cell_events.mat'));
    %load(fullfile(files(i).folder, 'startframe.mat'));
    load(fullfile(files(i).folder, 'zscored_cell.mat'));
    
        file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(count,1) = currentfile;
     btime = length(timestamp.behavecam);
   behavior = ones(btime,1);
    %isolate selective cells
  %interactions = ones(size(interactions));
%   
%     zscored_cell(:,[h k]) = [];
zscored_cell_filt = zscored_cell;
%     %cell_events=cell_events(:,idx);

    
    for ii = [2] 
       % behavior = interactions(:,ii);
        [AUC] = get_AUC_approach(5, zscored_cell_filt, timestamp, behavior);
        final_results{count,(count2+1)} = mean(AUC);
    end
end 
end
