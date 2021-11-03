p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','obj_interactions.mat'));
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,5,1);


for i = 1:numExps
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    %load(fullfile(files(i).folder, 'startframe.mat'));
    
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
    
   for ii = [2,3]
       %2 = periphery
       %3 = center
       %4 = velocity
       %5 = distance traveled
       
       behavior = interactions(:,ii);
       final_results{i,ii} = [];
        if ii == 9
           final_results{i,4} = mean(behavior);
        elseif ii == 10
           final_results{i,5} = sum(behavior);
        else
      
       [percent_time, seconds] = behavior_times(behavior, 1, timestamp);
       final_results{i,ii} = percent_time*100;
       end
       
   end
end