p_folder = uigetdir('D:\Users\Connor Johnson\Desktop\ACC Figures\goodhill_lab_data\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_trace.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,5,1);

for i = 1:numExps
    
    load(fullfile(files(i).folder, 'idx_open.mat'));
    idx_openLR = idx;
    load(fullfile(files(i).folder, 'idx_closed.mat'));
    idx_closedLR = idx;
    
     file_delim = strsplit(files(i).folder, '\');
     x = 'Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\';
     currentfile = join(file_delim(7:10),'\');
     curr = strcat(x,char(currentfile));
     final_results(i,1) = currentfile;
      
    load(fullfile(curr, 'idx_open.mat'));
    idx_openROC = idx;
    load(fullfile(curr, 'idx_closed.mat'));
    idx_closedROC = idx;
     
    overlap_closed = intersect(idx_closedLR,idx_closedROC);
    overlap_open = intersect(idx_openLR,idx_openROC);
    
    final_results{i,2} = (size(overlap_closed,2)/size(idx_closedROC,2))*100;
    final_results{i,3} = (size(overlap_open,2)/size(idx_openROC,2))*100;
    final_results{i,4} = (size(idx_closedLR,2)/size(idx_closedROC,2))*100;
    final_results{i,5} = (size(idx_openLR,2)/size(idx_openROC,2))*100;
    
end
