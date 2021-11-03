p_folder = uigetdir('D:\Users\Connor Johnson\Desktop\ACC Figures\goodhill_lab_data\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_trace.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);
tic

for i = [1,3:numExps]
    
    load(fullfile(files(i).folder, 'binned_zscore.mat'));
    load(fullfile(files(i).folder, 'binned_behavior.mat'));
    
    behavior_states = binned_behavior';
    zscored_cell_filt = binned_zscore;
    
    file_delim = strsplit(files(i).folder, '\');
    x = 'Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\';
    currentfile = join(file_delim(7:10),'\');
    curr = strcat(x,char(currentfile));
    final_results(i,1) = currentfile;

    load(fullfile(curr, 'idx_closed.mat'));
    idx_openROC = idx;
    
    %find closed
    Y = behavior_states(:,1);
    %find open
    Y1 = behavior_states(:,2);
    %set open = 2 and closed = 1
    Y2 = Y + 2*Y1;
    Y2(Y2 == 0) = 1;
    Y2(Y2 == 3) = 1;
    
    %now reduce the sampled closed to using the same # of frames as open
    behave_temp = Y2;
    open = find(Y2 == 2);
    closed = find(Y2 == 1);
    
    %for that one trial that wants to be a pain, if open is > closed make
    %them equal
    if size(open,1) > size(closed,1)
        open = open(1:size(closed,1));
    end
    
    %create matrix for holding final results
    trial_phat = zeros(size(idx_openROC));
    %go through and assess cell by cell    
    for ii = 1:size(idx_openROC,2)
       %temp variable for when we are doing 1000 loops
        phat_temp = zeros(size(idx_openROC,2),1);
        %assess the cell 1000 times using 70% of data to train
        parfor iii = [1:100]
            
            %create training matrix (70% of observation)
            %randomly select which closed cells to use
            closed_eq = randperm(size(closed,1),size(open,1));
            closed_2 = closed(closed_eq);
            %randomly select which closed frames to use
            x = randperm(size(open,1),round(size(open,1)*.7));

            %set X = ca2+ traces with the same indices as the open and closed
            %frames
            X = zscored_cell_filt([open(x) closed_2(x)],idx_openROC(1:ii));
            %create behavior matrix with equal open and closed frames
            Y3 = Y2([open(x), closed_2(x)]);
            Y3 = vertcat(Y3(:,1),Y3(:,2));
            opent = open;
            closedt = closed_2;
            opent(x) = [];
            closedt(x) = [];
            Ytest = Y2([opent, closedt]);
            Ytest = vertcat(Ytest(:,1),Ytest(:,2));
            %creat testing matrices (30% of observation)
            Xtest = zscored_cell_filt([opent closedt],idx_openROC(1:ii));
            
            
            
            %run LR
            [B,DEV,STATS] = mnrfit(X,Y3);
            
            phat = mnrval(B,Xtest);
            
            %determine mean phat values
            p = mean(phat(1:size(opent,1),2));
            p2 = mean(phat(size(opent,1):end,2));
            phat_temp(iii) = p;
        end
        trial_phat(ii) = mean(phat_temp);
    end
    
    save(fullfile(files(i).folder, 'trial_phat.mat'),'trial_phat');
end
toc