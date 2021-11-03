%% Values to Set

%Enter the columns of the DLCcoordinates.csv for each marker w/ likelihood
snout = 50:52; 
head =50:52;  
centroid =50:52;
center=2:3;
topleftin=5:6;
topleftout=8:9;
toprightin=11:12;
toprightout=14:15;

bottomleftin=17:18;
bottomleftout=20:21;
%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;


%% Gather video names and locations for analysis
p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized');
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv')); 
logs = is_split(logs);
coord_idx = true(length(logs),1);
logs = logs(coord_idx);
numFiles = length(logs);
 
distance=cell(numFiles,2,1);
velocity=cell(numFiles,2,1);
transition=cell(numFiles,5,1);

for i = 1:numFiles
%     try
         if ~exist(fullfile(logs(i).folder,'obj_interactions.mat'),'file')
            s = regexp(logs(i).folder, '\', 'split');
            fprintf('Filtering matrix %.0f of %.0f: %s %s %s\n',i,numFiles,s{6},s{7},s{8})
               load(fullfile(logs(i).folder,'timestamp.mat'));
            [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
            file_delim = strsplit(logs(i).folder, '\');
           currentfile = join(file_delim(7:9));
           distance(i,1) = currentfile;
           velocity(i,1) = currentfile;
           transition(i,1) = currentfile;
            interactions = zeroMaze(NUM(:,[center,topleftin,topleftout,toprightin,bottomleftin,bottomleftout]),NUM(:,[snout, head, centroid]), VideoReader(fullfile(logs(i).folder,'behavCam1.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam1_ROI0717.avi')),timestamp.behavecam(:,3), thresh);
            
            [m,~] = size(NUM(:,[snout,head]));
            
            displacement=0;
            vel=0;
            
            for j=1:m
                displacement=displacement+interactions(j,10);
                if(~isinf(interactions(j,9)))
                    vel=vel+interactions(j,9);
                end
            end
            
            vel=vel/m;
            distance(i,2)=num2cell(displacement);
            velocity(i,2)=num2cell(vel);
            
            to_open=0;
            from_open=0;
            to_close=0;
            from_close=0;
            
            for j=11:m-10;
              
                A=all(interactions(j-10:j,2)==0);
                if(A==1)
                    B=all(interactions(j+1:j+10,2)~=0);
                    if(B==1)
                        to_close=to_close+1;
                    end
                end  
                
                A=all(interactions(j-10:j,2)==1);
                if(A==1)
                    B=all(interactions(j+1:j+10,2)~=1);
                    if(B==1)
                        from_close=from_close+1;
                    end
                end  
                
                A=all(interactions(j-10:j,3)==0);
                if(A==1)
                    B=all(interactions(j+1:j+10,3)~=0);
                    if(B==1)
                        to_open=to_open+1;
                    end
                end    
                
                A=all(interactions(j-10:j,3)==1);
                if(A==1)
                    B=all(interactions(j+1:j+10,3)~=1);
                    if(B==1)
                        from_open=from_open+1;
                    end
                end    
            end
            
            
            transition(i,2)=num2cell(from_open);
            transition(i,3)=num2cell(to_close);
            transition(i,4)=num2cell(from_close);
            transition(i,5)=num2cell(to_open);
            
            fprintf("     Saving...\n")
            save(fullfile(fullfile(logs(i).folder,'obj_interactions.mat')),'interactions')
            clear NUM;
%         else
%             disp('Matrix already completed')
        end
%     catch
%          warning('Error on matrix #%d: %s\n', i, logs(i).name)
      
end

%Analyze Videos

function interactions = zeroMaze(coord,snout, oldv, newv, time, thresh)
    [m,~] = size(snout);
    interactions = cell(m+1,10);
    
    %Set titles
    interactions{1,1} = "Frame";
    interactions{1,2} = "Closed";
    interactions{1,3} = "Open";
    interactions{1,4} = "Top";
    interactions{1,5} = "Bottom";
    interactions{1,6} = "Left";
    interactions{1,7} = "Right";
    interactions{1,8} = "HeadDip";
    interactions{1,9} = "Speed";
    interactions{1,10} = "Distance";
    
    open(newv);
    
    %Make ROI's
    [center, radius1, radius2] = findMid(coord);
    radius2 = abs(radius2);
    ROIo = drawcircle('Center',center,'Radius',radius1-3,'StripeColor','red');
    ROIi = drawcircle('Center',center,'Radius',radius2+4,'Color','blue');
    
    %Set bounds where the closed arms open
    bound1 = floor(center(1) - round(radius2 * 0.80)); %top bound
    bound2 = floor(center(1) + round(radius2 * 0.80)); %bottom bound
%      

    width = sqrt(((coord(1,3)-coord(1,7)).^2) + ((coord(1,4)-coord(1,8)).^2));
    pix_per_m = width/0.33;

%     
%      time(1) = 0;
%      time2 = [0 time'];
%      time_dif = ((time') - time2(1:m))/1000; 
    
    for i = 2:(m+1)
        
        s=0;
        
        %choose snout or head based on DLC confidence
        if (snout(i-1,3) >= thresh)
              coords = snout(i-1,1:2);
              if (i==2)
                  prev = snout(i-1,1:2);
              else
                  prev = snout(i-2,1:2);
              end
              chance = true;
         else
             if(snout(i-1,6) >= thresh)
                 coords(2) = snout(i-1,5);
                 coords(1) = snout(i-1,4);
                 if (i==2)
                     prev = snout(i-1,4:5);
                 else
                 prev = snout(i-2,4:5);
                 end
                 chance = true;
             else
                 chance = false;
             end
        end

        
             
        %Fill in interactions array based om DLC coordinates
        interactions{i,1} = i-1;
        centroid = snout(i-1,7:8);
        if (chance)
            interactions{i,2} = false;
            interactions{i,3} = false;
            interactions{i,4} = false;
            interactions{i,5} = false;
            interactions{i,6} = false;
            interactions{i,7} = false;
            interactions{i,8} = false;
            
             dis=0;
        
         if (i == 2)
            interactions{i,9}=0;
         else
            dis = sqrt(((coords(1)-prev(1)).^2) + ((coords(2)-prev(2)).^2));
            dis = dis/pix_per_m;
            interactions{i,9} = dis*30;%time_dif(i-1);
         end 
        interactions{i,10}=dis;

            if(centroid(2) < bound1)
               interactions{i,2} = true; %Closed
               interactions{i,4} = true; %Top
            elseif(centroid(2) > bound2)
                interactions{i,2} = true; %Closed
                interactions{i,5} = true; %Bottom
            else
                interactions{i,3} = true; %Open
                if(centroid(1) < 220) 
                    interactions{i,6} = true; %Left
                     if (inROI(ROIi,coords(2),coords(1)))
                         interactions{i,8} = true; %Headdip inside
                     elseif (inROI(ROIo,coords(2),coords(1)))
                        interactions{i,8} = false; %No head dip
                     else
                         interactions{i,8} = true; %Head dip ouside
                     end 
                else
                    interactions{i,7} = true; %Right
                     if (inROI(ROIi,coords(2),coords(1))) %Head dip inside
                         interactions{i,8} = true; %Head dip inside
                     elseif (inROI(ROIo,coords(2),coords(1)))
                        interactions{i,8} = false; %No head dip
                     else
                         interactions{i,8} = true; %Head dip outside
                     end 
                end
            end
        end
        
        

        if hasFrame(oldv)
            frame = readFrame(oldv);


            %Mark snout/head
            if(chance)
                n = round(coords(1)); %horizontal 
                m = round(coords(2)); %vertical
                [y,x,~] = size(frame); x = x-4; y = y -4;
                if ((m < y) && (m > 4))
                    if ((n < x) && (n > 4))
                        %Magenta for headdip
                        if(interactions{i,8} == true) 
                            frame((m-3):(m+3),(n-3):(n+3),1) = 187;
                            frame((m-3):(m+3),(n-3):(n+3),2) = 86;
                            frame((m-3):(m+3),(n-3):(n+3),3) = 149;
                        %Blue for top 
                        elseif(interactions{i,4} == true)          
                            frame((m-3):(m+3),(n-3):(n+3),1) = 56;
                            frame((m-3):(m+3),(n-3):(n+3),2) = 61;
                            frame((m-3):(m+3),(n-3):(n+3),3) = 150;
                        %Green for bottom
                        elseif(interactions{i,5} == true) 
                            frame((m-3):(m+3),(n-3):(n+3),1) = 70;
                            frame((m-3):(m+3),(n-3):(n+3),2) = 148;
                            frame((m-3):(m+3),(n-3):(n+3),3) = 73;
                        %Orange for left
                        elseif(interactions{i,6} == true)
                            frame((m-3):(m+3),(n-3):(n+3),1) = 214;
                            frame((m-3):(m+3),(n-3):(n+3),2) = 126;
                            frame((m-3):(m+3),(n-3):(n+3),3) = 44;
                        %Yellow for right
                        elseif(interactions{i,7} == true) 
                            frame((m-3):(m+3),(n-3):(n+3),1) = 231;
                            frame((m-3):(m+3),(n-3):(n+3),2) = 199;
                            frame((m-3):(m+3),(n-3):(n+3),3) = 31;
                        end
                    end
                end
            end

            %Mark bound 1
            frame((bound1-1):(bound1+1),:,1) = 175;
            frame((bound1-1):(bound1+1),:,2) = 54;
            frame((bound1-1):(bound1+1),:,3) = 60;

            %Mark bound 2
            frame((bound2-1):(bound2+1),:,1) = 100;
            frame((bound2-1):(bound2+1),:,2) = 54;
            frame((bound2-1):(bound2+1),:,3) = 200;

            in1 = true;
            in2 = true;
            %Mark ROI inner and oute
            Vertices1 = round(ROIi.Vertices);
            for e = 1:length(Vertices1)
                if (in1 == true)
                    frame(Vertices1(e,1),Vertices1(e,2),1) = 175;
                    frame(Vertices1(e,1),Vertices1(e,2),2) = 54;
                    frame(Vertices1(e,1),Vertices1(e,2),3) = 60;
                end
            end
%                 if(~isempty(objinfo{10}))
                Vertices2 = round(ROIo.Vertices);
                for e = 1:length(Vertices2)
                    if (in2 == true)
                        frame(Vertices2(e,1),Vertices2(e,2),1) = 175;
                        frame(Vertices2(e,1),Vertices2(e,2),2) = 54;
                        frame(Vertices2(e,1),Vertices2(e,2),3) = 60;
                    end
                end
%                 end
            writeVideo(newv, frame);   
         end
    end
    close(newv);
    mat = zeros(length(snout),8);
    for j = 1:length(snout)
        if (~isempty(interactions{j+1,1}))
            mat(j,1) = interactions{j+1,1};
        end
        
        if (~isempty(interactions{j+1,2}))
            mat(j,2) = interactions{j+1,2};
        end
        
        if (~isempty(interactions{j+1,3}))
            mat(j,3) = interactions{j+1,3};
        end
        
        if (~isempty(interactions{j+1,4}))
            mat(j,4) = interactions{j+1,4};
        end
        
        if (~isempty(interactions{j+1,5}))
            mat(j,5) = interactions{j+1,5};
        end
        
        if (~isempty(interactions{j+1,6}))
            mat(j,6) = interactions{j+1,6};
        end
        if (~isempty(interactions{j+1,7}))
            mat(j,7) = interactions{j+1,7};
        end
        if (~isempty(interactions{j+1,8}))
            mat(j,8) = interactions{j+1,8};
        end
        if (~isempty(interactions{j+1,9}))
            mat(j,9) = interactions{j+1,9};
        end
        if (~isempty(interactions{j+1,10}))
            mat(j,10) = interactions{j+1,10};
        end
    end
    interactions = post_filt(mat, 10);
end

%Filter out head dips less than thresh # of frames
function interactions = post_filt(mat,thresh)
    lines = diff(mat(:,8));
    starts = find(lines > 0);
    stops = find(lines < 0);
    if (length(starts) < length(stops))
        starts = [1; starts];
    elseif (length(starts) > length(stops))
        stops = [stops; length(mat)];
    end
    lengths = stops - starts;
    blips = find(lengths <= thresh);
    for i = 1:length(blips)
        mat(starts(blips(i)):stops(blips(i)),8) = 0;
    end
    interactions = mat;
end

%Find center and radius of the maze using a binary of the first frame
function [center,radius1, radius2] = findCenter(frame)
    fprintf("     Locating center...\n")
    [m,n] = size(frame(:,:,1));
    bandw = imbinarize(frame(:,:,1),0.5);
    i = 1;
    while (bandw(i,round(n/2)) == false)
        i = i +1;
    end
    j = 1;
    while (bandw(round(m/2),j) == false)
        j = j +1;
    end
    k = m;
    while (bandw(k,round(n/2)) == false)
        k = k - 1;
    end
    radius1 = (k-i)/2;
    center = [i+radius1,j+radius1];
    j2 = j;
    while (bandw(round(m/2),j2) == true)
        j2 = j2 + 1;
    end
    radius2 = radius1 - (j2 - j);
end

function [center,radius1,radius2] = findMid(field)

fprintf(" Locating center and radii...\n")

fixed=mean(field);


center(1)=fixed(1)+8;
center(2)=fixed(2)-8;

cx=fixed(1);
cy=fixed(2);

radius2= (sqrt(((fixed(3)-cx)^2)+((fixed(4)-cy)^2))+sqrt(((fixed(7)-cx)^2)+((fixed(8)-cy)^2)))/2;
radius1= (sqrt(((fixed(5)-cx)^2)+((fixed(6)-cy)^2))+sqrt(((fixed(11)-cx)^2)+((fixed(12)-cy)^2)))/2;


end

function [speeds, quart_labels] = peaks_per_quart(speeds, behavTime)

    behavTime(1) = 0;
    
    last_second = floor(behavTime(end)/1000);
    extra = mod(behavTime(end),last_second*1000);
    if (extra > 0)
       last_second = last_second + 1;
    end
    seconds = (1:last_second);
    
    %bin behavior time by seconds
    fprintf('\t Binning behavior time\n')
    new_behavTime = zeros(length(behavTime));
    bindex = 1;
    for i = 1:length(behavTime)
        if (behavTime(i) < seconds(bindex)*1000)
            new_behavTime(i) = seconds(bindex); 
        else
            bindex = bindex + 1;
            new_behavTime(i) = seconds(bindex);
        end
    end
    
    fprintf('\t Finding average speed/sec\n')
    tiles = quantile(speeds,4);
    quart_labels = zeros(length(speeds),1);
    for i = seconds
        rows = find(new_behavTime == i);
        avg_speed =  mean(speeds(rows));
        speeds(rows) = avg_speed;
        if (avg_speed <= tiles(1))
            quart_labels(rows) = 1;
        elseif (avg_speed <= tiles(2))
            quart_labels(rows) = 2;
        elseif (avg_speed <= tiles(3))
            quart_labels(rows) = 3;
        else
            quart_labels(rows) = 4;
        end
    end
    
end

function speed = scalc(current,last,pix_per_m, time)
    dist = sqrt(((current(1)-last(1)).^2) + ((current(2)-last(2)).^2));
    dist = dist/pix_per_m;
    speed = dist/time;
end