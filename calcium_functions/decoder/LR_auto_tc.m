p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_cell.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);


for i = 1:12
    
    %Load files from server
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    load(fullfile(files(i).folder, 'idx_closed.mat'));
    closed = idx;
    load(fullfile(files(i).folder, 'idx_open.mat'));
    open = idx;
    corr_curves = struct([]);
%     zscore = zscored_cell_filt(:,[open closed]);
   zscored_cell_filt(:,[open closed])=  [];
    zscore =  zscored_cell_filt;
    x = 0:0.05:5;
    x = x';
    tc = [];
    rsq = [];
    for ii = 1:size(zscore,2)
        xc = xcorr(zscore(:,ii),100,'normalized');
        [~,id] = max(xc);
        corr_curves(ii).sel =  xc(id:end);
        y = xc(id:end);
        [f,g] = fit(x,y,'exp2');

         rsq(ii) = g.rsquare;
            b= -1/f.b;
            d =-1/f.d;
            if b > d
                tc = [tc b];
            else
                tc = [tc d];
            end

         if tc(ii) > 1000
             plot(f,x,y)
         end
    end
    
    tcdata(i).tc = tc;
    tcdata(i).rsq = rsq;
    
 
    
 
end
%%
tc = horzcat(tcdata.tc);


 rsq = horzcat(tcdata.rsq);
% [t,i] = find(rsq > 0.95);
% tc = tc(i);