p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
files = dir(fullfile(p_folder,'**','timestamp.dat')); %to select directory from which .dat files will be pulled
numExps = length(files);

%The Purpose of this script is to extract the timestamp data from the 
%Timestamp.Dat file created with every recording in the UCLA Software
%Connor Johnson ACM Lab 1/2/2020

for i = 1:numExps
    %Initialize tempArray
    tempArray = [];
    % Find all msCam videos
    tempFiles = dir(fullfile(files(i).folder,'timestamp.dat'));
    
    for ii = 1:length(tempFiles)
        tempArray{ii} = fullfile(tempFiles(ii).folder,tempFiles(ii).name);     
        M=importdata(tempArray{ii}); %% This will create the matrix version        
        defaultcam = M.data(1,1);    
        
        cam1 = M.data(M.data(:,1) == defaultcam,:);
        cam2 = M.data(M.data(:,1) ~= defaultcam,:);
        
        %the behavior video should be longer than the mscam video
        if length(cam1) > length(cam2)           
            behavecam = cam1;
            mscam = cam2;
        else 
            behavecam = cam2;
            mscam = cam1;      
        end
      
        %save data into a struct
        timestamp=struct;
        timestamp.behavecam = behavecam;
        timestamp.mscam = mscam;
        save(fullfile(files(i).folder,'timestamp.mat'),'timestamp');
    end 
end
