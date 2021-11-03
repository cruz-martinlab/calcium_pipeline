p_folder = uigetdir('D:\Users\Connor Johnson\Desktop\ACC Figures\goodhill_lab_data\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','binned_zscore.mat'));
files = is_split(files);

numExps = length(files);
minbeh = zeros(7,2);
tic
struct
count=0;
for i = [1:8,11:13]
   count=count+1;
    load(fullfile(files(i).folder, 'binned_behavior.mat'));

    minbeh(count,1) = size(find(binned_behavior(1,:)==1),2);
    minbeh(count,2) = size(find(binned_behavior(2,:)==1),2);
end    
minframes=min(minbeh(:,1));

for i = [1:8,11:13]
    
    load(fullfile(files(i).folder, 'binned_zscore.mat'));
    load(fullfile(files(i).folder, 'binned_behavior.mat'));
    
    
    zscored_cell_filt = binned_zscore;
    closed = find(binned_behavior(1,:)==1);
    open = find(binned_behavior(1,:)==0);
    
    
    file_delim = strsplit(files(i).folder, '\');
    x = 'Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\';
    currentfile = join(file_delim(7:10),'\');
    curr = strcat(x,char(currentfile));
    
    load(fullfile(curr, 'idx_empty.mat'));
    idx_open = idx;
    load(fullfile(curr, 'idx_littermate.mat'));
    idx_closed = idx;
    
    x = [idx_open, idx_closed];
zscored_cell_filt=zscored_cell_filt(:,x);
     
    msopen = zscored_cell_filt(open(1:(minframes*3)),:);
    msclosed = zscored_cell_filt(closed(1:minframes),:);

    ms = vertcat([msopen ;msclosed]);
    frames(i).ms = ms;
    behavior = zeros(minframes*4,2);
    behavior(1:minframes,1) = 1;
    behavior(minframes:end,2) = 1;

end

behavior = zeros(minframes*4,2);
    behavior(1:minframes,1) = 1;
    behavior(minframes:end,2) = 1;
binned_zscore =[]
    
 for i = [1:numExps]
     
     
 binned_zscore = [ binned_zscore  frames(i).ms] ;
     
     
     
     
     
     end
     
     
     
     
     
     
  