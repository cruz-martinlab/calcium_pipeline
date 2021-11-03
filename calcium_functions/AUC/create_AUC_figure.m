p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','cell_events_filt.mat'));
files = is_split(files);
numExps = length(files);
hold off
close all

for i = 1:numExps
    
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'cell_events_filt.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    load(fullfile(files(i).folder, 'cuplocation.mat'));
    
    if cuplocation(1) == 1;
         interactions2 = interactions;
         interactions2(:,2) = interactions(:,3);
         interactions2(:,3) = interactions(:,2);
         interactions = interactions2;
    elseif cuplocation(2) == 1;
            interactions = interactions;
    end

    %define which cell you want to plot
    cell = 22;
    %the index of frames you want to plot
    idx = 2000:4000;
    
    %create your AUC vector
    z = zscored_cell_filt(idx,cell);
    z(interactions(idx,2) == 0) = 0;
    
    plot(zscored_cell_filt(idx,cell));
    hold on
    area(z);
end