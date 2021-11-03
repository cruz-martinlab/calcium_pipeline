function [AUC] = get_AUC_approach(approach, dff_cell_transients, timestamp, behavior)

%CJ ACM Lab 7/1/2020
%
%The purpose of this function is to find the AUC of our ca2+ data that
%align to our logical behavior data.
%
%INPUTS:
%Behavior = a logical matrix of whether or not an animal is performing a
%behavior. This can be a single column (one behavior) or multiple columns
%(multiple behaviors) if you want to bin different behaviors together.
%
%cell_AUC = The output from Jessica's code showing only transients - please
%make sure that it is 
%
%timestamp = the timestamp.mat file for the same trial as your behavior and
%ca2+ data.
%
%OUTPUT
%AUC = the average area under the curve of each cell 
    
    %create timestamps
    btime = timestamp.behavecam(:,3); btime(1) = 0;
    mstime = timestamp.mscam(:,3); mstime(1) = 0;
    t = approach*30;
    
    %find instances of behavior
    soc = find(behavior == 1); 
    if size(soc,1) > 0
        
        totalcells = size(dff_cell_transients,2);
        startstop = [];
        startstop = [startstop soc(1)]; %first behavior frame
        
        %find all the *start* and *stop* frames
        for i = 1:length(soc)           
            if i+1 <= length(soc)
                if (soc(i+1) - soc(i)) > 2
                startstop = [startstop soc(i)];
                startstop = [startstop soc(i+1)];
                end
            end
        end
        startstop = [startstop soc(length(soc))]; %last behavior frame
       
                
        startstop2 = vec2mat(startstop, 2);   
        framecheck = startstop2(:,2) - startstop2(:,1);
        startstop3 = [];
        f = framecheck >300;
        check = 0;
        
        
        for i=1:length(f)
            check = check+2;
            if f(i) == 0
             startstop3 = [ startstop3 startstop(check-1)];   
               startstop3 = [startstop3 startstop(check)]   ;
            elseif f (i) == 1
                x = startstop2(i,1):150:startstop2(i,2); 
                startstop3 = [startstop3 x(1)];
                for ii = 1:size(x,2)-1
                      startstop3=[startstop3 x(ii)];
                      startstop3=[startstop3 x(ii)+1];
                end
                 startstop3=[startstop3 x(end)];
            end
        end
        startstop = vec2mat(startstop3, 2);
        check = startstop(:,1) - startstop(:,2);
        startstop = startstop(find(check ~= 0),:);
        int_length = (startstop(:,2) - startstop(:,1));
        startstop = startstop(int_length > 20,:);

        
        start = startstop;
        
        start(:,2) = startstop(:,1) + t;
        start = start(start(:,2) < size(behavior,1),:);
        startstop = start;
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
            [~,idx] = min(abs(mstime - startstoptimes(v,1)));
            spikeframe = [spikeframe idx];
            [~,idx] = min(abs(mstime - startstoptimes(v,2)));
            spikeframe = [spikeframe idx];
        end
        spikeframe = vec2mat(spikeframe, 2);
        
        %create stop start frames struct
        startstopframes = struct;
        startstopframes.mscam = spikeframe;
        startstopframes.behavecam = startstop;
        
        AUC = [];
        for ii = 1:totalcells
            auc_temp = [];
            for iii = 1:size(spikeframe,1)
                g = spikeframe(iii,1):spikeframe(iii,2);
                auc = trapz(dff_cell_transients(g,ii));
                auc_temp = [auc_temp auc];
            end
            AUC = [AUC mean(auc_temp)];
        end
        
  
        
    end
        
end
    