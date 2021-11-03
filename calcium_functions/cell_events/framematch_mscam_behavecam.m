function[cellfreq, startstopframes, totaltime] = framematch_mscam_behavecam(behavior, cell_events, timestamp)

%CJ ACM Lab 5/9/2020
%
%The purpose of this function is to find the frames of our ca2+ data that
%align to our logical behavior data.
%
%INPUTS:
%Behavior = a logical matrix of whether or not an animal is performing a
%behavior. This can be a single column (one behavior) or multiple columns
%(multiple behaviors) if you want to bin different behaviors together.
%
%cells = Ca2+ data that you want to align to your behavioral data. This can
%be in the form of raw traces or a logical matrix of peaks.
%
%timestamp = the timestamp.mat file for the same trial as your behavior and
%ca2+ data.
%
%OUTPUT
%startstopframes = a struct with the start and stop frames for each
%instance of behavior. Both for your behavioral data and for your ca2+ data
%
%totaltime = the total time of each behavior instance, helpful for
%calculating frequency
    
    %create timestamps
    btime = timestamp.behavecam(:,3); btime(1) = 0;
    mstime = timestamp.mscam(:,3); mstime(1) = 0;
    
    
    %find instances of behavior
    soc = find(behavior == 1); 
    if size(soc,1) > 0
        
        totalcells = size(cell_events,2);
        startstop = [];
        startstop = [startstop soc(1)]; %first behavior frame
        
        %find all the *start* and *stop* frames
        for i = 1:length(soc)           
            if i+1 <= length(soc)
                if (soc(i+1) - soc(i)) > 10
                startstop = [startstop soc(i)];
                startstop = [startstop soc(i+1)];
                end
            end
        end
        startstop = [startstop soc(length(soc))]; %last behavior frame 
        startstop = vec2mat(startstop, 2);
        check = startstop(:,1) - startstop(:,2);
        startstop = startstop(find(check ~= 0),:);
        int_length = (startstop(:,2) - startstop(:,1));
        startstop = startstop(int_length > 20,:);
        startstoptimes = startstop;
        %find the timestamps that correlate to the behavior frames
        for i = 1:size(startstop,1)
            startstoptimes(i, 1) = btime(startstop(i,1));
            startstoptimes(i, 2) = btime(startstop(i,2));
        end
        %calculate lenth of behavior since we have the data all out on the
        %table
        totaltime = [];
        for v = 1:size(startstop,1)
            b = diff(startstoptimes(v,:));
            totaltime = [totaltime b];
        end
        totaltime = totaltime'/1000;
        
        %find the mscam frames that correlate to the behavior frames
        spikeframe = [];
        for v = 1:size(startstop,1)
            [val,idx] = min(abs(mstime - startstoptimes(v,1)));
            spikeframe = [spikeframe idx];
            [val,idx] = min(abs(mstime - startstoptimes(v,2)));
            spikeframe = [spikeframe idx];
        end
        spikeframe = vec2mat(spikeframe, 2);
        
        %create stop start frames struct
        startstopframes = struct;
        startstopframes.mscam = spikeframe;
        startstopframes.behavecam = startstop;
        
        cell_events = double(cell_events > 0);
        totalevents = zeros(size(spikeframe,1),size(cell_events,2));
        for i = 1:size(spikeframe,1)
            g = spikeframe(i,1):spikeframe(i,2);
            totalevents(i,:) = sum(cell_events(g,:));
        end
        
        cellfreq = sum(totalevents,1);
        time = sum(totaltime);
        cellfreq = cellfreq/time;
        
    end
        
end
    