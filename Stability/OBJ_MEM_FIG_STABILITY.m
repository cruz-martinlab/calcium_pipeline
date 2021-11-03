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
for i = 1:4:numExps
    
    count = count + 1;
    load(fullfile(files(i).folder, 'cell_events.mat'));
    %load files from day 1
    load(fullfile(files(i).folder, 'idx_obj1.mat'));
    idx_open_1 = idx;

    %load(fullfile(files(i).folder, 'idx_headdip.mat'));
    %idx_headdip_1 = idx;
    
    %load files from day 2
    load(fullfile(files(i+1).folder, 'idx_obj1.mat'));
    idx_open_2 = idx;


    %load files from day 3
    load(fullfile(files(i+2).folder, 'idx_obj1.mat'));
    idx_open_3 = idx;


    %load files from day 4
    load(fullfile(files(i+3).folder, 'idx_obj1.mat'));
    idx_open_4 = idx;

    %find the true percentages of stable cells
    overlap_open = intersect(idx_open_1,idx_open_2);
    open_stable = ((size(overlap_open,2))/(size(idx_open_1,2)))*100;

    overlap_open_3  = intersect(overlap_open,idx_open_3);
    open_stable_3  = ((size(overlap_open_3,2))/(size(idx_open_1,2)))*100;

    overlap_open_4  = intersect(overlap_open_3,idx_open_3);
    open_stable_4  = ((size(overlap_open_4,2))/(size(idx_open_1,2)))*100;
    
    %find total number of selective cells on day 2
    day2_selective = size(idx_open_2,2);
    %find total number of cells registered for this animal
    total_cells_reg = size(cell_events,2);
    open_rand_per = zeros(1,1000);
    open_rand_per_3 = zeros(1,1000);
    open_rand_per_4 = zeros(1,1000);
    for ii = 1:1000
        selective_rand = randperm(total_cells_reg,day2_selective);

        open_rand = randperm(total_cells_reg,size(idx_open_2,2));
        open_rand_3 = randperm(total_cells_reg,size(idx_open_3,2));
        open_rand_4 = randperm(total_cells_reg,size(idx_open_3,2));
        
        %calculate random stability
        open_stable_rand = intersect(idx_open_1,open_rand);
        open_stable_rand_per = ((size(open_stable_rand,2))/(size(idx_open_1,2)))*100;
        
        open_stable_rand_3 = intersect(open_stable_rand,open_rand_3);
        open_stable_rand_per_3 = ((size(open_stable_rand_3,2))/(size(idx_open_1,2)))*100;
        
        open_stable_rand_4 = intersect(open_stable_rand_3,open_rand_4);
        open_stable_rand_per_4 = ((size(open_stable_rand_4,2))/(size(idx_open_1,2)))*100;
        
        open_rand_per(ii) = open_stable_rand_per;
        open_rand_per_3(ii) = open_stable_rand_per_3;
        open_rand_per_4(ii) = open_stable_rand_per_4;
    end
    
    %create 2 std threshold for stability
    open_stdthresh = quantile(open_rand_per,0.95);
    
    open_stdthresh_3 = quantile(open_rand_per_3,0.95);
    open_stdthresh_4 = quantile(open_rand_per_4,0.95);
    
    %find cells that surpass threshold
    open_selective = open_stable > open_stdthresh;
    
    open_selective_3 = open_stable_3 > open_stdthresh_3;
    
    open_selective_4 = open_stable_4 > open_stdthresh_4;
    
    %save results in final matrix
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(8:10));
    final_results(count,1) = currentfile;
    final_results{count,2} = size(idx_open_1,2);
    final_results{count,3} = open_stable;
    final_results{count,4} = open_rand_per';
    final_results{count,5} = open_selective;
    final_results{count,6} = size(idx_open_2,2);;
    final_results{count,7} = open_stable_3;
    final_results{count,8} = open_rand_per_3';
    final_results{count,9} = open_selective_3;

    
end