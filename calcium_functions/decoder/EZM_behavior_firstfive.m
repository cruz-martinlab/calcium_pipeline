p_folder = uigetdir();
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','obj_interactions.mat'));
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,5,1);

%
% Get the behavior results from only the beginning of behavior
% To determine what length you want to analyze set variable frames_ms
% frames_ms input is miliseconds, to analyze the first 5 minutes of the
% trial use frames_ms = 300000
% 60,000 ms per minute
%

frames_ms = 300000;

for i = 1:numExps
    %load files
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'startframe.mat'));
    
    %get trial name
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
    
    %get behavior times
   for ii = [2,3,8]
       behavior = interactions(:,ii);
       if sum(behavior) == 0
       final_results{i,ii} = [];
       else
           if ii == 8
                   final_results{i,4} = percent_time*100;
                   final_results{i,5} = size(seconds,1);
           else
           [percent_time, seconds] = behavior_times_parttrial(frames_ms, behavior, startframe, timestamp);
           final_results{i,ii} = percent_time*100;
           end
       end
   end
       
end
