function [zscored_cell,cell_transients,cell_events, cell_AUC, dff_cell_transients]=detect_ca_transients()

p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');
files = dir(fullfile(p_folder,'**','raw_trace.mat'));
numExps = length(files);


thresh = 2;
baseline = 0.5;
t_half = 0.2;
FR = 20;

%Ca transient event detection, adapted from Dombeck 2007
%author Jessica Jimenez, Columbia University, jcj2123@columbia.edu

%Edits by Connor Johnson, ACM Lab, Boston University 4/8/2020

%inputs
%raw_cell= Ca2 transient data in TxN format, N=cells (columns), T=time (rows), raw format
%thresh= minimum amplitude size of ca transient in s.d.
%baseline= s.d. offset value of ca transient
%t_half= half life of gcamp type used (s), if taken from Chen TW et al Nature 2013, gcamp6f t_half=0.200 s
%FR= framerate of raw_cell

%outputs
%cell_transients= TxN matrix with s.d. values for all the timepoints of the qualified transients (all zeros except for transients, red trace in fig)
%cell_events= TxN matrix with calcium transient peak events (all zeros except for the amplitude value at the peak timepoint of each transient, asterisk in fig)
%cell_AUC= TxN matrix with calcium transient area under the curve (AOC) values (all zeros except for the AOC value assigned to the peak timepoint of each transient)
%zscored_cell= TxN matrix with zscored raw_cell data (blue trace in fig)

% the above 4 outputs will be saved into a .mat in your directory called
% "ca2events", and each cell figure will also be saved showing the event
% detection performance

for i = 1:numExps

tempFiles = dir(fullfile(files(i).folder,'raw_trace.mat')); %temporary variable holding the Ca traces of the current trial
load(fullfile(tempFiles.folder, tempFiles.name));
raw_trace = squeeze(raw_trace);
raw_cell = raw_trace';

%zscore your data
pophist=reshape(raw_cell,[],1); % generate single vector with all cell fluorescence values
pop_offset=quantile(pophist,0.50); %find the 50% quantile value (for "silent" time points)
silent=pophist<pop_offset; %find timepoints without ca transients based on threshold above
mu=mean(pophist(silent==1)); % specify mu from the silent timepoints
[~, ~, sigma] = zscore(raw_cell,1); %specify sigma from the entire time series
zscored_cell = bsxfun(@rdivide, bsxfun(@minus, raw_cell, mu), sigma); %convert transients into zscores using mu from silent timepoints and sigma from all timepoints

celldata=zscored_cell;

%preallocate outputs
tk=size(celldata);
cell_transients=zeros(tk);
dff_cell_transients = zeros(tk);
cell_events=zeros(tk);
cell_AUC=zeros(tk);

%define minimum duration of calcium transient based on gcamp type used
decayrate=0.693/t_half; %simplified from (-ln(A/Ao)/t_half), [A/Ao]=0.5 at t half-life, [-ln(A/Ao)]=0.693
minduration=-(log(baseline/thresh))/decayrate; %minimum (s) duration for ca transient of minimum specified s.d. amplitude threshold
minframes= round(minduration*FR); %minimum number of frames the ca transient should last above baseline

%identify qualified ca transients and generate outputs
for k=1:size(celldata,2);
    
    onset=find(celldata(:,k)>thresh); %find all timepoints where flourescence greater than threshold
    offset=find(celldata(:,k)>baseline); %find all timepoints where floursecence greater than baseline (transient offset)
    
    found=1;
    for m = 1:length(offset)-1
        
        if found == 1
            start = offset(m); %specify start index of transient from offset vector
            found = 0;
        end
        
        if offset(m+1) - offset(m) > 1 %specify stop index of transient from offset vector
            finish = offset(m);
            [M,I]=max(celldata(start:finish,k)); %find the peak value in that start-stop range
            transientvect=start:finish;
            maxamp_ind=transientvect(I); %retrieve "cell" index of that peak value
            peak_to_offset_vect=maxamp_ind:finish;
            found  = 1;
            
            if ismember(maxamp_ind,onset)>0 && length(peak_to_offset_vect)>=minframes; %if the peak value index from start-stop in offset is also found in onset vector, the transient exceeded the 2SD threshold
                cell_transients(start:finish,k) = celldata(start:finish,k); %retrieve "cell" values for all the timepoints of that transient
                dff_cell_transients(start:finish,k) = raw_cell(start:finish,k); %get cell_transients with df/f values instead of z scored
                cell_events(maxamp_ind,k)=M; %create a matrix with all the calcium transient peak events (all zeros except for the amplitude value at the peak timepoint)
                transient_area=trapz(celldata(start:finish,k)); %integrate the area under the curve of the transient from start-stop
                cell_AUC(maxamp_ind,k)=transient_area; %create a matrix with all the calcium transient AOC values (all zeros except for the AOC value assigned to the peak timepoint)
            end
            
        end
        if m== length(offset)-1 %dealing with the last index in the vector, same as above
            finish= offset(m+1);
            [M,I]=max(celldata(start:finish,k));
            transientvect=start:finish;
            maxamp_ind=transientvect(I);
            peak_to_offset_vect=maxamp_ind:finish;
            found  = 1;
            if ismember(maxamp_ind,onset)>0  && length(peak_to_offset_vect)>=minframes;
                cell_transients(start:finish,k) = celldata(start:finish,k);
                cell_events(maxamp_ind,k)=M;
                transient_area=trapz(celldata(start:finish,k));
                cell_AUC(maxamp_ind,k)=transient_area;
            end
        end
        
    end
    
end




% detect multi-peak transients & update in cell_events

for k=1:size(cell_transients,2);
    
    [~, time]=findpeaks(cell_transients(:,k),'MinPeakProminence',1.5,'MinPeakDistance',FR); %built-in matlab 'findpeaks' fxn
    %minpeak distance is 1 sec (as specified by your frame rate), and min peak
    %prominence must be 1.5SD in size
    cell_events(time,k)=cell_transients(time,k); % cell events with multi-peak transients added
end


%plot and save figures with event detection results
X=(1:size(cell_events,1))';
events=cell_events;
events(events==0)=NaN;

save(fullfile(files(i).folder,'cell_transients'), 'cell_transients'); 
save(fullfile(files(i).folder,'cell_events'),'cell_events');
save(fullfile(files(i).folder,'zscored_cell'),'zscored_cell');

save(fullfile(files(i).folder,'dff_cell_transients'), 'dff_cell_transients');

end
end

