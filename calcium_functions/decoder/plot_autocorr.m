p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_cell.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);

close all
for i = 1
    
    %Load files from server
    load(fullfile(files(i).folder, 'timestamp.mat'));
    load(fullfile(files(i).folder, 'zscored_cell_filt.mat'));
    load(fullfile(files(i).folder, 'idx_closed.mat'));
    closed = idx;
    load(fullfile(files(i).folder, 'idx_open.mat'));
    open = idx;
    corr_curves = struct([]);
      zscore = zscored_cell_filt(:,[open closed]);
%    zscored_cell_filt(:,[open closed])=  [];
%     zscore =  zscored_cell_filt;
    x = 0:0.05:5;
    x = x';
    tc = [];
    rsq = [];
    pp  = 0;
    p = 0;
    for ii = 1:size(zscore,2)
        pp = pp+1;
        xc = xcorr(zscore(:,ii),100,'normalized');
        [~,d] = max(xc);
        corr_curves(ii).sel =  xc(d:end);
        y = xc(d:end);
        [f,g] = fit(x,y,'exp2');
         rsq(ii) = g.rsquare;
            b= -1/f.b;
            d =-1/f.d;
            if b > d
                tc = [tc b];
            else
                tc = [tc d];
            end
%             if tc(pp) >0
                p =p+1;
                subplot(4,4,p)
                hold on
                timec = string(tc(pp));
                nnn = string('time constant =');
                if rsq(ii) > 0.95
                 plot(f,'g')
                 plot(x,y,'b o')
                 legend(append(nnn,timec),'Data')
                else
                 plot(f,'r')
                 plot(x,y,'b o')
                 legend(append(nnn,timec),'Data')
                end
          
    end
end