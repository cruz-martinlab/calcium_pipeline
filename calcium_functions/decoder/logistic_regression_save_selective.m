p_folder = uigetdir('D:\Users\Connor Johnson\Desktop\ACC Figures\goodhill_lab_data\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_trace.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);

for i = 1:numExps
    
    load(fullfile(files(i).folder, 'zscored_trace.mat'));
    load(fullfile(files(i).folder, 'behavior_states.mat'));
    
    %find closed
    Y = behavior_states(:,1);
    %find open
    Y1 = behavior_states(:,2);
    %set open = 2 and closed = 1
    Y2 = Y + 2*Y1;
    %Y2(Y2 == 0) = 1;
    Y2(Y2 == 3) = 2;
    
    %now reduce the sampled closed to using the same # of frames as open
    behave_temp = Y2;
    open = find(Y2 == 2);
    closed = find(Y2 == 1);
    
    %randomly select which closed cells to use
    x = randperm(size(closed,1),size(open,1));
    
    %set X = ca2+ traces with the same indices as the open and closed
    %frames
    X = zscored_cell_filt([open closed(x)],:);
    %create behavior matrix with equal open and closed frames
    Y2 = Y2([open, closed(x)]);
    Y2 = vertcat(Y2(:,1),Y2(:,2));
    %create matrix for holding final results
    idx_open = [];
    idx_closed = [];

    %go through and assess cell by cell    
    for ii = 1:size(zscored_cell_filt,2)
       %temp variable for when we are doing 1000 loops
        idx_temp = zeros(100,1);
        X1 = X(:,ii);
        %assess the cell 1000 times using 70% of data to train
        for iii = 1:100
            
            %sample 70% of data equal from open and closed
            u = randperm(size(open,1), round((size(open,1)*.7)));
            closed_u = (size(open,1)+u);
            Y_closed = Y2(closed_u);
            Y_open = Y2(u);
            Y3 = [Y_open Y_closed];
            Y3 = vertcat(Y3(:,1),Y3(:,2));
            X2 = X1([u closed_u]);
            
            %run LR
            [B,DEV,STATS] = mnrfit(X2,Y3);
            
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