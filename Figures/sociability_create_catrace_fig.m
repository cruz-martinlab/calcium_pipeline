p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','idx_novel.mat')); %to determine the folder of each trial
files = is_split(files);
numExps = length(files);
hold off
close all

for i = 1:numExps
   

    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'cuplocation.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    load(fullfile(files(i).folder, 'cell_events.mat'));
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'idx_novel.mat'));
    idx_center = idx;
%     load(fullfile(files(i).folder, 'idx_closed.mat'));
%     idx_periphery = idx;
    
    %for neutral
    %x = [idx_center, idx_periphery]
    %zscored_cell_filt(:,idx) =[];
        

    if cuplocation(1) == 1;
        interactions2 = interactions;
        interactions2(:,2) = interactions(:,3);
        interactions2(:,3) = interactions(:,2);
        interactions = interactions2;
    end

        
    %Prep variables for analysis
    zscored_cell_filt=zscored_cell_filt(:,idx);
    cell_events_filt=cell_events;
    zscored = zscored_cell_filt;
    
    %get empty/novel frames and match to ms frames
    behavior = interactions(:,3); 
    [cellfreq, startstopframes, totaltime] = framematch_mscam_behavecam(behavior, cell_events_filt, timestamp);
    %ms frames equivalent to empty/novel
    msframes = startstopframes.mscam;
    
    %%get empty/novel frames
    avg_zscore = mean(zscored_cell_filt,2);
    in_open = zeros(1,size(zscored_cell_filt,1));
    for ii = 1:size(msframes,1)
        in_open(msframes(ii,1):msframes(ii,2)) = max(max(zscored));
    end
    
    %get littermate frames and match to ms frames
    behavior = interactions(:,2);
    [cellfreq, startstopframes, totaltime] = framematch_mscam_behavecam(behavior, cell_events_filt, timestamp);
    %ms frames equivalent to littermate
    msframes = startstopframes.mscam;
    
    %%get littermatte frames
    in_closed = zeros(1,size(zscored_cell_filt,1));
    for ii = 1:size(msframes,1)
        in_closed(msframes(ii,1):msframes(ii,2)) = max(max(zscored));
    end
   
    
    for ii = 1:size(zscored,2)
        ii 
        area(in_closed,'LineStyle','none','FaceColor','g');
        alpha(0.25)
        hold on
        area(in_open,'LineStyle','none','FaceColor','r');
        alpha(0.25)
        plot(smooth(zscored(:,ii)),'Color','#0072BD','LineWidth',1.25);
        %xlim([0 12000])
        ylim([-1 max(zscored(:,i))])
        x = input('Look at next trace?');
    hold off
    end
    
end