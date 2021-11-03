p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\Registration');
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
    x = 'Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\registration\EZM_OF\';
    currentfile = join(file_delim(9:11),'\');
    y = 'Open_Field\';
    curr = strcat(x,y,char(currentfile));
    
    %load files from day 2
    load(fullfile(curr, 'idx_center.mat'));
    idx_open_2 = idx;
    load(fullfile(curr, 'idx_periphery.mat'));
    idx_closed_2 = idx;
    %load(fullfile(files(i).folder, 'idx_headdip.mat'));
    %idx_headdip_2 = idx;
    
    %find the true percentages of stable cells
    overlap_closed = intersect(idx_closed_1,idx_closed_2);
    closed_stable = ((size(overlap_closed,2))/(size(idx_closed_1,2)))*100;
    overlap_open = intersect(idx_open_1,idx_open_2);
    open_stable = ((size(overlap_open,2))/(size(idx_open_1,2)))*100;
    overlap_open_3 = intersect(idx_open_1,idx_closed_2);
    overlap_closed_3 = intersect(idx_closed_1,idx_open_2);


    
    
    %find total number of selective cells on day 2
    day2_selective = size(idx_closed_2,2)+size(idx_open_2,2);
    %find total number of cells registered for this animal
    total_cells_reg = size(cell_events,2);
    closed_rand_per = zeros(1,1000);
    open_rand_per = zeros(1,1000);
    for ii = 1:1000
        selective_rand = randperm(total_cells_reg,day2_selective);
        closed_rand = selective_rand(1:size(idx_closed_2,2));
        open_rand = selective_rand((size(idx_closed_2,2)+1):size(selective_rand,2));
        
        %calculate random stability
        closed_stable_rand = intersect(idx_closed_1,closed_rand);
        open_stable_rand = intersect(idx_open_1,open_rand);
        closed_stable_rand_per = ((size(closed_stable_rand,2))/(size(idx_closed_1,2)))*100;
        open_stable_rand_per = ((size(open_stable_rand,2))/(size(idx_open_1,2)))*100;
        
        closed_rand_per(ii) = closed_stable_rand_per;
        open_rand_per(ii) = open_stable_rand_per;
        
    end
    
    %create 2 std threshold for stability
    closed_stdthresh = quantile(closed_rand_per,0.95);
    open_stdthresh = quantile(open_rand_per,0.95);
    
    %find cells that surpass threshold
    closed_selective = closed_stable > closed_stdthresh;
    open_selective = open_stable > open_stdthresh;
    
    %save results in final matrix
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(9:11));
    final_results(count,1) = currentfile;
    final_results{count,2} = size(idx_closed_1,2);
    final_results{count,3} = closed_stable;
    final_results{count,4} = mean(closed_rand_per);
    final_results{count,5} = closed_selective;
    final_results{count,6} = size(idx_open_1,2);
    final_results{count,7} = open_stable;
    final_results{count,8} = mean(open_rand_per);
    final_results{count,9} = open_selective;
    final_results{count,10} = overlap_open_3;
    final_results{count,11} = overlap_closed_3;

    
    
    
    
end