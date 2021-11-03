p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','timestamp.mat'));
%files = is_split(files);
numExps = length(files);
final_results = cell(numExps,2,1);


for i = 1:numExps
    
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
 
    f = exist(fullfile(files(i).folder,'idx_open.mat'));
    
    if f == 0
        final_results{i,2} = 0;
    else 
        final_results{i,2} = 1;
    end
    
end