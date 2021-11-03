p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
files = dir(fullfile(p_folder,'**','zscored_cell.mat'));
files = is_split(files);

numExps = length(files);
final_results = cell(numExps,3,1);


for i = 1:numExps

    %Load files from server
    load(fullfile(files(i).folder, 'A.mat'));
    A = full(A);
    A = reshape(A,480,752,size(A,2));
    A = A(:,:,idx+1);
    A = sum(A,3);
    imagesc(A);
    cmap = gray(256);
    colormap(cmap);

end





