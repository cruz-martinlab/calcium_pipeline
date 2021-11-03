close all
clear all
clc
p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','cupidbinary.xlsx'));
charfname = char(fullfile(files.folder,'cupidbinary.xlsx'));

M=readtable(charfname);
M=table2cell(M);
M=M(:,4:5);

numExps = length(files);
files = dir(fullfile(p_folder,'**','timestamp.mat'));
files = is_split(files);
numExps = length(files);


for i = 1:numExps;
    cuplocation = cell2mat(M(i,:));
    save(fullfile(files(i).folder,'cuplocation.mat'), 'cuplocation');
end

