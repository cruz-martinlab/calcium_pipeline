p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','idx_obj1.mat'));
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,5,1);


for i = 3:4:numExps
      if ~exist(fullfile(files(i).folder,'idx_novel.mat'));

    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'cuplocation.mat'));
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
%      load(fullfile(files(i).folder, 'startframe.mat'));

    
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
%     
%     if cuplocation(1) == 1;
%          interactions2 = interactions;
%          interactions2(:,2) = interactions(:,3);
%          interactions2(:,3) = interactions(:,2);
%          interactions = interactions2;
%     elseif cuplocation(2) == 1;
%         interactions2 = interactions;
%          interactions2(:,4) = interactions(:,6);
%            interactions2(:,6) = interactions(:,4);
%          interactions = interactions;
%     end

       btime = (timestamp.behavecam(end,3))/1000;
   for ii = 2
       behavior = interactions(:,ii);
       [percent_time, seconds] = behavior_times(behavior, startframe, timestamp);
       final_results{i,ii} = percent_time*100;
   end
      end
end