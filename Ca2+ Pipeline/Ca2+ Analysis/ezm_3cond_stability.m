p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','cell_events.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);

%Determine the % of selective cells that are stable across 2 days.
%Shuffle 1000 times to see if this is random.
%10/1/20 Connor Johnson, ACM Lab Boston Univeristy

count = 0;
for i = 1:numExps
    
    count = count + 1;
    load(fullfile(files(i).folder, 'cell_events.mat'));
    %load files from day 1
    load(fullfile(files(i).folder, 'idx_open.mat'));
    idx_open_1 = idx;
    load(fullfile(files(i).folder, 'idx_closed.mat'));
    idx_closed_1 = idx;

    file_delim = strsplit(files(i).folder, '\'); 
    x = 'Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\registration\EZM_3cond\';
    currentfile = join(file_delim(9:11),'\');
    y = 'Zero_Maze_Bright\';
    curr = strcat(x,y,char(currentfile));
    
    %load files from ezm bright
    load(fullfile(curr, 'idx_open.mat'));
    idx_open_b = idx;
    load(fullfile(curr, 'idx_closed.mat'));
    idx_closed_b = idx;

     file_delim = strsplit(files(i).folder, '\'); 
    x = 'Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\registration\EZM_3cond\';
    currentfile = join(file_delim(9:11),'\');
    y = 'Zero_Maze_Dim\';
    curr = strcat(x,y,char(currentfile));
    
    %load files from ezm dim
    load(fullfile(curr, 'idx_open.mat'));
    idx_open_d = idx;
    load(fullfile(curr, 'idx_closed.mat'));
    idx_closed_d = idx;

    
    %find the true percentages of stable cells
    overlap_closed_normdim = intersect(idx_closed_1,idx_closed_d);
    closed_stable_normdim = ((size(overlap_closed_normdim,1))/(size(idx_closed_1,2)))*100;
    overlap_open_normdim = intersect(idx_open_1,idx_open_d);
    open_stable_normdim = ((size(overlap_open_normdim,2))/(size(idx_open_1,2)))*100;
    overlap_closedopen_normdim = intersect(idx_open_1,idx_closed_d);
    overlap_openclosed_normdim = intersect(idx_closed_1,idx_open_d);
    
    %find the true percentages of stable cells
    overlap_closed_normbright = intersect(idx_closed_1,idx_closed_b);
    closed_stable_normbright = ((size(overlap_closed_normbright,2))/(size(idx_closed_1,2)))*100;
    overlap_open_normbright = intersect(idx_open_1,idx_open_b);
    open_stable_normbright = ((size(overlap_open_normbright,2))/(size(idx_open_1,2)))*100;
    overlap_closedopen_normbright = intersect(idx_open_1,idx_closed_b);
    overlap_openclosed_normbright = intersect(idx_closed_1,idx_open_b);
    
    
    %find the true percentages of stable cells
    overlap_closed_dimbright = intersect(idx_closed_b,idx_closed_d);
    closed_stable_dimbright = ((size(overlap_closed_dimbright,2))/(size(idx_closed_1,2)))*100;
    overlap_open_dimbright = intersect(idx_open_b,idx_open_d);
    open_stable_dimbright = ((size(overlap_open_dimbright,2))/(size(idx_open_1,2)))*100;
    overlap_closedopen_dimbright = intersect(idx_open_d,idx_closed_b);
    overlap_openclosed_dimbright = intersect(idx_closed_d,idx_open_b);
    
%     %find total number of selective cells on day 2
%     day2_selective = size(idx_closed_2,2)+size(idx_open_2,2);
%     %find total number of cells registered for this animal
%     total_cells_reg = size(cell_events,2);
%     closed_rand_per = zeros(1,1000);
%     open_rand_per = zeros(1,1000);
%     
%     for ii = 1:1000
%         selective_rand = randperm(total_cells_reg,day2_selective);
%         closed_rand = selective_rand(1:size(idx_closed_2,2));
%         open_rand = selective_rand((size(idx_closed_2,2)+1):size(selective_rand,2));
%         
%         %calculate random stability
%         closed_stable_rand = intersect(idx_closed_1,closed_rand);
%         open_stable_rand = intersect(idx_open_1,open_rand);
%         closed_stable_rand_per = ((size(closed_stable_rand,2))/(size(idx_closed_1,2)))*100;
%         open_stable_rand_per = ((size(open_stable_rand,2))/(size(idx_open_1,2)))*100;
%         
%         closed_rand_per(ii) = closed_stable_rand_per;
%         open_rand_per(ii) = open_stable_rand_per;
%         
%     end
%     
%     %create 2 std threshold for stability
%     closed_stdthresh = quantile(closed_rand_per,0.95);
%     open_stdthresh = quantile(open_rand_per,0.95);
%     
%     %find cells that surpass threshold
%     closed_selective = closed_stable > closed_stdthresh;
%     open_selective = open_stable > open_stdthresh;
%     
% %     %save results in final matrix
%      file_delim = strsplit(files(i).folder, '\');
%      currentfile = join(file_delim(9:11));
%      final_results(count,1) = currentfile;
%      final_results{count,2} = closed_selective;
%      final_results{count,3} = open_selective;
%     
    
    
    
end