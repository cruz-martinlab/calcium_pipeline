p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','cell_events.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,17,1);

%Connor Johnson 10/16/20 ACM Lab Boston University
%
%The purpose of this code is to extract the cells that encode only one
%condition from our EZM and Day 1 Sociability registered data

for i = 1:numExps
    
    %Load files from the EZM Registered Data (Post auROC)
    load(fullfile(files(i).folder, 'idx_open.mat'));
    load(fullfile(files(i).folder, 'cell_events.mat'));
    idx_open = idx;
    load(fullfile(files(i).folder, 'idx_closed.mat'));
    idx_closed = idx;
    
    %Find registered Sociability folder
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(9:11));
    final_results(i,1) = currentfile;
    file_delim{8} = 'Sociability';
%     file_delim{10} = 'Day_2';
    
    soc_file = string(join(file_delim,'\'));
    
    %Load files from the EZM Registered Data (Post auROC)
    load(fullfile(soc_file, 'idx_littermate.mat'));
    idx_fam = idx;
    load(fullfile(soc_file, 'idx_empty.mat'));
    idx_empty = idx;
    
    %Find # of CLOSED ONLY CELLS
    closed_open = size(intersect(idx_closed, idx_open),2);
    closed_fam = size(intersect(idx_closed, idx_fam),2);
    closed_empty = size(intersect(idx_closed, idx_empty),2);
    final_results{i,2} = size(idx_closed,2) - closed_open - closed_fam - closed_empty;
    
    %Find # of OPEN ONLY CELLS
    open_fam = size(intersect(idx_open, idx_fam),2);
    open_empty = size(intersect(idx_open, idx_empty),2);
    final_results{i,3} = size(idx_open,2) - closed_open - open_fam - open_empty;
    
    %Find # of LITTERMATE ONLY CELLS
    fam_empty = size(intersect(idx_fam,idx_empty),2);
    final_results{i,4} = size(idx_fam,2) - closed_fam - open_fam - fam_empty;
    
    %Find # of EMPTY ONLY CELLS
    final_results{i,5} = size(idx_empty,2) - closed_empty - open_empty - fam_empty;
    
    %Find the Rest of Cells
    final_results{i,6} = closed_open;
    final_results{i,7} = closed_fam;
    final_results{i,8} = closed_empty;
    final_results{i,9} = open_fam;
    final_results{i,10} = open_empty;
    final_results{i,11} = fam_empty;
    final_results{i,12} = size(intersect(intersect(idx_closed, idx_open), idx_fam),2);
    final_results{i,13} = size(intersect(intersect(idx_closed, idx_open), idx_empty),2);
    final_results{i,14} = size(intersect(intersect(idx_closed, idx_fam), idx_empty),2);
    final_results{i,15} = size(intersect(intersect(idx_open,idx_fam), idx_empty),2);
    final_results{i,16} = size(intersect(intersect(intersect(idx_open, idx_fam), idx_empty), idx_closed),2);
    final_results{i,17} = size(cell_events,2);
    
    
    
    
end

final_results{7,1} = 'TOTAL CELLS';

for i = 2:17
final_results{7,i} = sum([final_results{:,i}]);
end
