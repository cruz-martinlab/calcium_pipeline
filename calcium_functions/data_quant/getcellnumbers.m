close all
clear all
clc
p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','raw_trace.mat'));
files = is_split(files);


numExps = length(files);
final_results = cell(numExps,2,1);


for i = 5:8:numExps
    load(fullfile(files(i).folder, 'raw_trace_filt.mat'));
    raw_trace = raw_trace_filt;
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    final_results(i,1) = currentfile;
    num_cells = size(raw_trace,1);
    final_results{i,2} = num_cells;
end
