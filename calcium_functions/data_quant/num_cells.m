p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','raw_trace.mat')); %to determine the folder of each trial
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,2,1);

for i = 1:numExps
   

%    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'raw_trace.mat'));
  %  load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));


    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
    
    final_results{i,2} = size(raw_trace,1);
    

end


final_results{i+1,2} = sum([final_results{:,2}]);