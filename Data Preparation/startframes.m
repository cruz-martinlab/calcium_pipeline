p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','startframes.xlsx')); %to determine the folder of each trial
charfname = char(fullfile(files.folder,'startframes.xlsx'));

%open table
M=readtable(charfname);
M=table2cell(M);
g = M(:,2);
g = cell2mat(g);
y = find(g >= 1);

%save row with startframes
start = cell2mat(M(y, 5));

%This code is meant to distribute the startframe of a trial into its trial
%folder based off of the startframes.xlsx sheet in the behavior folder.
%Make sure that the start frames sheet does not include split trials.

%find the folders to distribute the startframe variables
files = dir(fullfile(p_folder,'**','raw_trace.mat'));
files = is_split(files);
numExps = length(files);

for i = 1:numExps
    startframe = start(i);
    save(fullfile(files(i).folder,'startframe.mat'),'startframe');
end