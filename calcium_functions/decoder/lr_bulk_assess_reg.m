p_folder = uigetdir('D:\Users\Connor Johnson\Desktop\ACC Figures\goodhill_lab_data\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','binned_zscore_1.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);
tic
for i = [1:numExps]
    
    load(fullfile(files(i).folder, 'binned_zscore_1.mat'));
    binned_zscore1 = binned_zscore;
    load(fullfile(files(i).folder, 'binned_zscore_2day2.mat'));
    binned_zscore2=binned_zscore;
    load(fullfile(files(i).folder, 'behavior2.mat'));
%     load(fullfile(files(i).folder, 'pred_addcellsday2_2.mat'));
%     
    zscored_cell_filt = binned_zscore1;
     pred_addcells = zeros(50,1000);
    
    %go through and assess cell by cell    
    for ii = 1:50
       %temp variable for when we are doing 100 loops
        pred_temp = zeros(1000,1);
        %assess the cell 1000 times using 70% of data to train
        parfor iii = [1:1000]
                %find beh 1
                Y = behavior(:,1);
                %find beh 2
                Y1 = behavior(:,2);
                %set beh1 = 1 and beh2 = 2
                Y2 = Y + 2*Y1;
                %filter and possible overlap that is due to DLC
                Y2(Y2 == 3) = 1;

            %get random cell index based on number of cells we want to eval
            rand_cells = randperm(size(zscored_cell_filt,2),ii);
            binned_zscore1_r=binned_zscore1(:,rand_cells);
            
            [Y_70, Y_30, X_70, X_30] = split_data_70_30(binned_zscore1_r, behavior);
            
            %run LR
            [B,DEV,STATS] = mnrfit(X_70,Y_70);

%              binned_zscore2_r=binned_zscore2(:,rand_cells);
%                            [Y_70, Y_30, X_70, X_30] = split_data_70_30(binned_zscore2_r, behavior);
            phat = mnrval(B,X_30);
            pred_open = phat(:,1) < 0.5;
            pred_temp(iii) = mean((pred_open + 1) == Y_30);
        end
        pred_addcells(ii,:) = pred_temp;
    end
    
    save(fullfile(files(i).folder, 'pred_addcells_day2.mat'),'pred_addcells');
end
toc