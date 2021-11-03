p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','raw_trace.mat'));
files = is_split(files);
numExps = length(files);
final_results = cell(numExps,3,1);

for i = 1:numExps
    
    %load files needed for this script
    load(fullfile(files(i).folder, 'raw_trace.mat'));
    load(fullfile(files(i).folder, 'cell_events.mat'));
    load(fullfile(files(i).folder, 'zscored_cell.mat'));
    load(fullfile(files(i).folder, 'cell_transients.mat'));
    load(fullfile(files(i).folder, 'timestamp.mat'));
    %load(fullfile(files(i).folder, 'dff_cell_transients.mat'));
    %load(fullfile(files(i).folder, 'A_cell_locations.mat'));
    raw_trace = squeeze(raw_trace);
    %get file names for final result cell
    file_delim = strsplit(files(i).folder, '\');
    currentfile = join(file_delim(7:9));
    
    %column 1 is the file name
    final_results(i,1) = currentfile;
    
    %run function to filter the bad cells
    [raw_trace_filt, cell_events_filt, cell_transients_filt, zscored_cell_filt, idx] = filter_cells(raw_trace,cell_events, cell_transients, zscored_cell, timestamp);
    
    %column 2 is the original number of cells
    final_results{i,2} = size(raw_trace,1);
    
    %column 3 is the number of cells after filtering
    final_results{i,3} = size(raw_trace_filt,1);
    filtered_cells_idx = idx;
    
    %dff_cell_transients_filt = dff_cell_transients(:,idx);
    %A = A1(:,:,idx);
    
    %save filtered traces and cell events back to trial folder
     save(fullfile(files(i).folder,'raw_trace_filt'), 'raw_trace_filt');
     save(fullfile(files(i).folder,'cell_events_filt'), 'cell_events_filt');
     save(fullfile(files(i).folder,'cell_transients_filt'), 'cell_transients_filt');
     save(fullfile(files(i).folder,'zscored_cell_filt'), 'zscored_cell_filt');
    save(fullfile(files(i).folder,'filtered_cells_idx'), 'filtered_cells_idx');
    %save(fullfile(files(i).folder,'dff_cell_transients_filt'), 'dff_cell_transients_filt');
end