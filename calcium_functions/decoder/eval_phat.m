p_folder = uigetdir('D:\Users\Connor Johnson\Desktop\ACC Figures\goodhill_lab_data\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','trial_phat_closed.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);
close all
hold on
for i = 1:numExps
    
    load(fullfile(files(i).folder, 'trial_phat_ind_vip.mat'));

        file_delim = strsplit(files(i).folder, '\');
    x = 'Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\';
    currentfile = join(file_delim(7:10),'\');
    curr = strcat(x,char(currentfile));
     load(fullfile(curr, 'zscored_cell_filt.mat'));
     load(fullfile(curr, 'idx_open.mat'));
    idx_openROC = idx;
    load(fullfile(curr, 'idx_closed.mat'));
    idx_closedROC = idx;
    
    sel_idx = [idx_openROC idx_closedROC];
    zscored_cell_filt(:,sel_idx) = [];
     idx = zscored_cell_filt;
    final_results{i,1} = trial_phat(1:size(zscored_cell_filt,2),1)';
    p = 1:size(idx,2);
    p = p/size(idx,2);
    phat = [final_results{i,1}];
    %plot(p,phat)
end

%%

g = zeros(4,numExps);
f = [];
for i = 1:numExps
    
    phat = ([final_results{i,1}]);
    %plot((phat))
    f = [f max(phat)]
    hist(phat);
    pause('on')
%     if size(phat,2) >= 10
%         int = ceil(size(phat,2)/4);
%         plot(phat(1:int:end));
%         g(:,i) = phat(1:int:end);
%     end
    
    
end



%%
x = mean(g,2);