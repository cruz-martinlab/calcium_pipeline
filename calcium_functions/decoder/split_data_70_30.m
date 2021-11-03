% The purpose of this function is to split our behavior data into 70% and
% 30% portions of the original data set for evaluation in logistic
% regression or other decoders

function [Y_70, Y_30, X_70, X_30] = split_data_70_30(zscored_cell_filt, behavior)

    %find beh 1
    Y = behavior(:,1);
    %find beh 2
    Y1 = behavior(:,2);
    %set beh1 = 1 and beh2 = 2
    Y2 = Y + 2*Y1;
    %filter and possible overlap that is due to DLC
%     Y2(Y2 == 0) = 1;
     Y2(Y2 == 3) = 1;
    
    %now reduce the sampled closed to using the same # of frames as open
    beh2 = find(Y2 == 2);
    beh1 = find(Y2 == 1);
    
    %typically beh 1 is performed more than beh 2 but this line is here in
    %case the opposite is true
    if size(beh2,1) > size(beh1,1)
        beh2 = beh2(1:size(beh1,1));
    end
    
    %create training matrix (70% of observation)
    %randomly select which closed cells to use
    beh1_eq = randperm(size(beh1,1),size(beh2,1));
    beh1_2 = beh1(beh1_eq);
    %randomly select which beh frames to use
    x = randperm(size(beh2,1),round(size(beh2,1)*.7));
    
    %set X = ca2+ traces with the same indices as the beh1 and beh2
    %frames
    X_70 = zscored_cell_filt([beh2(x) beh1_2(x)],:);
    
    
    %create behavior matrix with equal open and closed frames
    Y3 = Y2([beh2(x), beh1_2(x)]);
    Y_70 = vertcat(Y3(:,1),Y3(:,2));
    
    %create our 30% testing vectors
    beh2_30 = beh2;
    beh1_30 = beh1_2;
    beh2_30(x) = [];
    beh1_30(x) = [];
    
    Ytest = Y2([beh2_30, beh1_30]);
    Y_30 = vertcat(Ytest(:,1),Ytest(:,2));
    
    %creat testing matrices (30% of observation)
    X_30 = zscored_cell_filt([beh2_30 beh1_30],:);

end