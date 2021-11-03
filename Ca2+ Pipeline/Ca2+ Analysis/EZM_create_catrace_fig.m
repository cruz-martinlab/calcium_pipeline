p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','cell_events.mat')); %to determine the folder of each trial
files = is_split(files);
numExps = length(files);
hold off
close all

for i = 1:numExps
   

    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    %load(fullfile(files(i).folder, 'cuplocation.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    load(fullfile(files(i).folder, 'cell_events.mat'));
    load(fullfile(files(i).folder, 'timestamp.mat'));
%     load(fullfile(files(i).folder, 'idx_closed.mat'));
%     idx_center = idx;
%     load(fullfile(files(i).folder, 'idx_open.mat'));
%     idx_periphery = idx;
    
    %for neutral
    %x = [idx_center, idx_periphery]
    %zscored_cell_filt(:,idx) =[];
    
    %Prep variables for analysis
%     zscored_cell_filt=zscored_cell_filt(:,idx);
    cell_events_filt=cell_events;
    zscored = zscored_cell_filt;
    
    %get open frames and match to ms frames
    behavior = interactions(:,3); 
    [cellfreq, startstopframes, totaltime] = framematch_mscam_behavecam(behavior, cell_events_filt, timestamp);
    %ms frames equivalent to open
    msframes = startstopframes.mscam;
    
    %Create variable of open arm frames equal to the height of the calcium trace
    avg_zscore = mean(zscored_cell_filt,2);
    in_open = zeros(1,size(zscored_cell_filt,1));
    for ii = 1:size(msframes,1)
        in_open(msframes(ii,1):msframes(ii,2)) = max(max(zscored));
    end
    
    %get closed frames and match to ms frames
    behavior = interactions(:,2);
    [cellfreq, startstopframes, totaltime] = framematch_mscam_behavecam(behavior, cell_events_filt, timestamp);
    msframes = startstopframes.mscam;
    
    %Create variable of closed arm frames equal to the height of the calcium trace
    in_closed = zeros(1,size(zscored_cell_filt,1));
    for ii = 1:size(msframes,1)
        in_closed(msframes(ii,1):msframes(ii,2)) = max(max(zscored));
    end
   
    %loop through cells
    for ii = 1:size(zscored,2)
        %print cell number

        
        %plot closed frames as green
        area(in_closed,'LineStyle','none','FaceColor','g');
        alpha(0.25)
        hold on
        
        %plot open frames as red
        area(in_open,'LineStyle','none','FaceColor','r');
        alpha(0.25)
        
        %plot ca2+ trace
%         plot(smooth(zscored(:,ii)),'Color','#0072BD','LineWidth',1.25);
%         ylim([-1 max(zscored(:,i))])
        
        %pause and ask if you want to see the next cell
        x = input('Do you want to see the next trace?');
        hold off
    end
    
end