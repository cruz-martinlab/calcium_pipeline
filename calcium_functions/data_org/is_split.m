function [files] = is_split(files)

numExps = length(files);

split = [];

for i = 1:numExps
    f = contains(files(i).folder, 'split');
    split = [split f];
end

files(split == 1) = [];