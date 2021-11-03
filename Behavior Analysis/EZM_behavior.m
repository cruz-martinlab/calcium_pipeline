p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','timestamp.mat'));
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,4,1);

%get behavior from zero maze
%final_results column 2 is closed, column 3 is open, column 4 is head dips
%(% time) and column 5 is number of headdips
count = 0;
%11,2,3,14,15
%1,7,13,4,10
%6,12,8,9,5
%[1:2:13,18,22,30,34,38]
for i = 1:2:numExps
    count = count+1;
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
   % load(fullfile(files(i).folder, 'startframe.mat'));
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(6:9));
    final_results(count,1) = currentfile;
    
    startframe=1;
   for ii = [2,3,8]
       behavior = interactions(:,ii);
       if sum(behavior) == 0
       final_results{count,ii} = [];
       else
        
       [percent_time, seconds] = behavior_times(behavior, startframe, timestamp);
       final_results{count,ii} = percent_time*100;
           if ii == 8
               final_results{count,4} = percent_time*100;
               final_results{count,5} = size(seconds,1);
           end
       end
   end
end