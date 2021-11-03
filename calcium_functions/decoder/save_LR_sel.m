p_folder = uigetdir('D:\Users\Connor Johnson\Desktop\ACC Figures\goodhill_lab_data\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_trace.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);
tic
for i = [1:numExps]
    
    load(fullfile(files(i).folder, 'binned_zscore.mat'));
    load(fullfile(files(i).folder, 'binned_behavior.mat'));
    
    behavior = binned_behavior';
    zscored_cell_filt = binned_zscore;
       idx_open = [];
    idx_closed = [];
        
     for ii = 1:size(zscored_cell_filt,2)
         idx_temp = zeros(100,1);
        parfor iii = 1:100
            %run 70-30 function
            [Y_70, Y_30, X_70, X_30] = split_data_70_30(zscored_cell_filt(:,ii), behavior);

            %run LR
            [B,DEV,STATS] = mnrfit(X_70,Y_70);
            
            %what does trial indicate about cell's selectiveness
            if B(1) > 0 && STATS.p(1) < 0.05
                idx_temp(iii) = 2;
            elseif B(1) < 0 && STATS.p(1) < 0.05
                idx_temp(iii) = 1;
            end
        end
        
        %see if cell was selective for either behavior > 70% of loops
        open_temp = find(idx_temp == 2);
        closed_temp = find(idx_temp == 1);
        
        if size(open_temp,1) > 70
            idx_open = [idx_open ii];
        elseif size(closed_temp,1) > 70
            idx_closed = [idx_closed ii];
        end
        
    end
    idx = idx_open;
    save(fullfile(files(i).folder, 'idx_open.mat'),'idx');
    idx = idx_closed;
    save(fullfile(files(i).folder, 'idx_closed.mat'),'idx');
end