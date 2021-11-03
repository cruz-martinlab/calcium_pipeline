p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','cell_events.mat'));
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,3,1);

%Save transitions for PCA analysis
%
%10/1/20 Connor Johnson, ACM Lab, Boston University
count=0;
for i = [1:2:11,13:3:numExps]
    
    count = count+1;
    traces = struct('periphery',1);
    
    %load files
    load(fullfile(files(i).folder, 'obj_interactions.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    load(fullfile(files(i).folder, 'cell_events_filt.mat'));
    load(fullfile(files(i).folder, 'timestamp.mat'));
    
%     load selective cells if wanted
     load(fullfile(files(i).folder, 'idx_open.mat'));
     open_idx = idx;
    load(fullfile(files(i).folder, 'idx_closed.mat'));
     closed_idx = idx;
    
%     UNCOMMENT TO GET ONLY NEUTRAL CELLS
    x = [open_idx, closed_idx];
    zscored_cell_filt(:,x) = [];

    %get file name

    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9),'_');
    final_results(count,1) = currentfile;
    
%     USE THIS TO SHIFT ALL CELLS (RANDOM CONTROL)
%      p1 = randperm(size(zscored_cell_filt,1),size(zscored_cell_filt,2));
%          for ii = 1:size(zscored_cell_filt,2);
%              zscored_cell_filt(:,ii) = circshift(zscored_cell_filt(:,ii),p1(ii),1);
%          end


    
    %how much time do you want to look at +/- behavior
    t = 10;
    raw_trace_filt = zscored_cell_filt(:,:);
    mtime = timestamp.mscam(:,3);
    
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
            tracesclosed = avgca;
        else 
            tracesopen = avgca;
        end
    end
    

    d = 201:20:401;
    frames = [];
    frames = [frames d(1)];
    for  ii = 2:length(d)-1
        frames = [frames d(ii)];
        frames = [frames d(ii)+1];
    end
    frames = [frames d(end)];
    
    d = vec2mat(frames,2);
    AUC = [];
    for iii = 1:size(d,1)
        auc_temp = [];
     for ii = 1:size(tracesclosed,2)
                g = d(iii,1):d(iii,2);
                auc = trapz(tracesclosed(g,ii));
                auc_temp = [auc_temp auc];
            end
            AUC = [AUC mean(auc_temp)];
    end
        
     final_results{count,2} = AUC;
    
    AUC = [];
    for iii = 1:size(d,1)
        auc_temp = [];
     for ii = 1:size(tracesopen,2)
                g = d(iii,1):d(iii,2);
                auc = trapz(tracesopen(g,ii));
                auc_temp = [auc_temp auc];
            end
            AUC = [AUC mean(auc_temp)];
    end
        
     final_results{count,3} = AUC;
    

    
end
    %%
    vertcat([final_results{:,2}])
vec2mat(ans,10)
    