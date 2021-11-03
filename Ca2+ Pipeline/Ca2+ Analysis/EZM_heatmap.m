p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','idx_open.mat'));
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,3,1);
traces = struct('periphery',1);

%This code was written in order to create visual representations of
%normalized average calcium activity of individual cells in the time
%surrounding a behavioral event.
%
%10/1/20 Connor Johnson, ACM Lab, Boston University

for i = 1:numExps
    %load files
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    load(fullfile(files(i).folder, 'cell_events_filt.mat'));
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'idx_open.mat'));
    mtime = timestamp.mscam(:,3);

    %how much time do you want to look at +/- behavior
    t = 10;
    %get file name
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
    
    %load selective cells
    raw_trace_filt = zscored_cell_filt(:,idx);
    
    %get frames
    for ii = 2:3
        behavior = interactions(:,ii);
        [~, startstopframes, ~] = framematch_mscam_behavecam(behavior, cell_events_filt, timestamp);
    
        %get indices we want to plot
        msframes = startstopframes.mscam;
        msframes(:,2) = msframes(:,1);
        msframes(:,1) = msframes(:,1) - t*20;
        msframes(:,2) = msframes(:,2) + t*20;
        msframes = msframes(msframes(:,1) > 0,:);
        msframes = msframes(msframes(:,2) < size(mtime,1),:);
        cells = struct('avg',1);

        %get traces from idices
        for iii = 1:size(msframes,1)
            x = raw_trace_filt(msframes(iii,1):msframes(iii,2),:);
            cells(iii).avg = x;
        end
        %average traces
        avgca = cells(1).avg;
        for v = 2:size(msframes,1)
            avgca = avgca + cells(v).avg;
        end
        avgca = avgca/size(msframes,1); 
        %save respective traces
        if ii == 2
            traces(i).periphery = avgca;
        else 
            traces(i).center = avgca;
        end
    end
    
end


%% Heatmap

%Here you can play around with the data. Find the field from the traces
%struct that you want to graph and change line 75 to implement. 

    %average all traces from one field
    avgca = horzcat(traces.periphery);
    %organize the traces based on time of max activity
    [x,y] = max(avgca);
    [o,u] = sort(y, 'ascend');
    sortavgca = avgca;
    for v = 1:length(u)
        sortavgca(:,v) = avgca(:,u(v));
    end
    %here you can optionally select the specific indices of your cells you
    %want to plot in order to make the figure look nicer
    
    %sortavgca = sortavgca(:,1:50);
    
    %here you will want to update that the seconds labeled on your x-axis
    %are accurate you original input 't'
    yy = imagesc(-10:0.01:10,1:size(o,2),sortavgca');
    caxis([0 1]);
    title('Closed Selective Cells')
    ylabel('Cell #')
    xlabel('Enter Open Arm (seconds)')
    pl = line([0,0], [size(o,2),0]);
    pl.Color = 'Black';
    pl.LineWidth = 1.5 ;
    colorbar
    
%% Normalized Heatmap

%this is essentially the same as the cell above except for lines 116-117
%which normalize the data. We found this makes for better figures and
%typically chose this method to represent ca2+ data in heatmaps. 

    avgca = horzcat(traces.center);
    g = mean(avgca(1:200,:)); 
    [o,u] = sort(g, 'ascend');
    sortavgca = avgca;
    for v = 1:length(u)
        sortavgca(:,v) = avgca(:,u(v));
    end
    
%     xxx = [1:13,15:24,27:31,33:36,38:47,49,50:54,56,59];
%     sortavgca = sortavgca(:,xxx);
    
    A = sortavgca;
    %!!!!THIS IS WHERE THE NORMALIZATION HAPPENS!!!!
    sortA = (A - min(A))./(max(A) - min(A));
    %DON'T FORGET
    
    yy = imagesc(-10:0.01:10,1:size(sortavgca,2),sortA');
    caxis([0 1]);
    title('Open Selective Camkii Cells')
    ylabel('Cell #')
    xlabel('Time From Entering Open Arm (seconds)')
    pl = line([0,0], [size(o,2),0]);
    pl.Color = 'Black';
    pl.LineWidth = 1.5 ;
    colorbar