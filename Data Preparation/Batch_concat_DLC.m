%Connor Johnson ACM Lab Boston University 2020
% IF you have an error of files named DLC_ or DeepCut_ please change lines
%
%
p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
files = dir(fullfile(p_folder,'**','raw_trace.mat')); %to determine the folder of each trial
numExps = length(files);
%files = is_split(files);
%object memory

%set fname to the string that is contained in the DLC file name
fname = 'DLC_';
%fname = 'DeepCut_';

tic
for i = 1:numExps
    %Initialize tempArray
    tempArray = [];
    % Find all msCam videos
    fileArray{i} = tempArray;
    
    tempFiles = dir(fullfile(files(i).folder,'behavCam*.csv')); %find all the DeepLabCut excel sheets within the trial folder
    why = size(tempFiles);
    if why(1) > 1
        
    x = [];
    
    for ii = 1:length(tempFiles)
        f = strsplit(tempFiles(ii).name, fname);
        x = [x f(1)];
    end
    
    if length(x) >= 10
        xx = x;
        xx(1:9) = x((length(x)-8):length(x));
        xx(10:length(x)) = x(1:length(x)-9);
    
    for ii = 1:length(xx)
        xx(ii) = strcat(xx(ii),fname,f(2)); 
    end
   
    T = struct2table(tempFiles);
    sortedT = sortrows(T, 'date');
    tempFiles = table2struct(sortedT); % This will organize the files incase there is a 10th or greater file 
    iwant = cell(length(xx),1);% this will create a cell where I can combine all my tables

    for ii = 1:length(xx)
        tempArray = char(fullfile(tempFiles(ii).folder,xx(ii)));
        M=readtable(tempArray, 'HeaderLines', 3); %% This will create a matrix from the excel file, which excludes the headers in the first 3 lines
        iwant{ii} = M; %iwant is a cell holding each matrix as the forloop runs its course
    end

    catmat = cat(1,iwant{:}); %this will concatanate the matrices in each cell
    frames = 1:height(catmat); 
    catmat = table2array(catmat);
    catmat(:,1) = frames;
    
    %now I will load the timestamp data and add corresponding timepoints to
    %the matrix
   % load(fullfile(files(i).folder,'timestamp.mat'));
   % timestamp.behavecam(1,3) = 0;
   % behavetimes = timestamp.behavecam(:,3);

    
    [num, txt, raw] = xlsread(tempArray);
    iwant = cell(2,1);
    iwant{1} = txt;
    iwant{2} = num2cell(catmat);
    finalmat = cat(1,iwant{:});
    writecell(finalmat, fullfile(files(i).folder,'DLCcoordinates.csv'));
    
    else
        
    iwant = cell(length(tempFiles),1);% this will create a cell where I can combine all my tables

    for ii = 1:length(tempFiles)
        tempArray{ii} = fullfile(tempFiles(ii).folder,tempFiles(ii).name);
        M=readtable(tempArray{ii}, 'HeaderLines', 3); %% This will create a matrix from the excel file, which excludes the headers in the first 3 lines
        iwant{ii} = M; %iwant is a cell holding each matrix as the forloop runs its course
    end

    catmat = cat(1,iwant{:}); %this will concatanate the matrices in each cell
    frames = 1:height(catmat); 
    catmat = table2array(catmat);
    catmat(:,1) = frames;
    
    [num, txt, raw] = xlsread(tempArray{ii});
    iwant = cell(2,1);

    iwant{1} = txt;
    iwant{2} = num2cell(catmat);
    finalmat = cat(1,iwant{:});
    writecell(finalmat, fullfile(files(i).folder,'DLCcoordinates.csv'));
    
    end
    end
    
    
    
    
end
toc