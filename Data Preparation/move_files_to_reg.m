p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\registration');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','raw_trace.mat'));
numExps = length(files);

for i = 1:numExps
    
    file_delim = strsplit(files(i).folder, '\');
    x = [1,2,3,4,5,8,9,10,11];
    currentfile = join(file_delim(x),'\');
    currentfile = string(currentfile);
    load(fullfile(currentfile, 'timestamp.mat'));
%         load(fullfile(currentfile, 'startframe.mat'));
    load(fullfile(currentfile, 'obj_interactions.mat'));
    
    f = exist(fullfile(currentfile,'cuplocation.mat'));
    
    if f == 2     
    load(fullfile(currentfile, 'cuplocation.mat'));
    save(fullfile(files(i).folder,'cuplocation'),'cuplocation');
    end
    
    save(fullfile(files(i).folder,'timestamp'),'timestamp');
    save(fullfile(files(i).folder,'obj_interactions'),'interactions');

    
      %  save(fullfile(files(i).folder,'startframe'),'startframe');

    
end
