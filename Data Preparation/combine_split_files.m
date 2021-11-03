p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');

logs = dir(fullfile(p_folder,'**','raw_trace.mat'));
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));

numExps=length(logs);
tochange= zeros(numExps,1);
count=0;
%% 

for i=1:numExps-1
    
    path_parts1 = regexp(logs(i).folder, '\', 'split');
    path_parts2 = regexp(logs(i+1).folder, '\', 'split');
    
    %See if the next 2 folders have 0split and 1split in their names

   f1 = contains(path_parts1(9), '0split');
   f2 = contains(path_parts2(9), '1split');
    
   %If they folders are split, concatenate their DLC and timestamps and save the original
   %folder
  if ((f1 ==1)&&(f2==1))
      %Concatenate DLC files
      count=count+1;
      DLC1=xlsread(fullfile(logs(i).folder,'DLCcoordinates.csv'));
      if isfile(fullfile(logs(i+1).folder,'DLCcoordinates.csv'));
      DLC2=xlsread(fullfile(logs(i+1).folder,'DLCcoordinates.csv'));
      allDLC=[DLC1;DLC2];
      else allDLC=DLC1;
      end    
      for j=1:length(allDLC)
          allDLC(j,1)=j;
      end
      
      
     writematrix(allDLC,fullfile(fullfile(logs(i-1).folder,'DLCcoordinates.csv')));
      
      %%Make a new timestamp
    load(fullfile(logs(i).folder,'timestamp.mat'))
    timestamp1 = timestamp;
    load(fullfile(logs(i+1).folder,'timestamp.mat'))
    timestamp2 = timestamp;

    %create first and second behavior matrices
    behav1 = timestamp1.behavecam;
    [m,n] = size(behav1);
    behav2 = timestamp2.behavecam;
    [m2,~] = size(behav2);
    behav2(1,3) = 0;
    %shift behav frame # and time down
    behav2(:,2) = behav2(:,2) + m;
    behav2(:,3) = behav2(:,3) + behav1(end,3);

    %create combined behavior time
    behav3 = zeros(m+m2,n);
    behav3(1:m,:) = behav1;
    behav3(m+1:end,:) = behav2;

    %create first and second mscam matrices
    ms1 = timestamp1.mscam;
    [m,n] = size(ms1);
    ms2 = timestamp2.mscam;
    [m2,~] = size(ms2);
    ms2(1,3) = 0;
    %shift ms frame # and time down
    ms2(:,2) = ms2(:,2) + m;
    ms2(:,3) = ms2(:,3) + ms1(end,3);

    %create combined ms time
    ms3 = zeros(m+m2,n);
    ms3(1:m,:) = ms1;
    ms3(m+1:end,:) = ms2;

    %put new matrices in a struct and save it
    timestamp = struct('behavecam',behav3,'mscam',ms3);
    fprintf("Saving timestamp\n")
    save(fullfile(logs(i-1).folder,'timestamp.mat'),'timestamp');
      
      clear DLC1;
      clear DLC2;
      clear allDLC;
     
  end
end

