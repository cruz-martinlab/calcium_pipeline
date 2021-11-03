%% Set values

%Enter the columns of the DLCcoordinates.csv w/ likelihood for each marker
l_corner = 2:4; %tl
r_corner = 5:7; %tr
bl_corner = 8:10; %bl
l_cup = 14:19; %north and south
r_cup = 26:31; %north and south
mouse = 38:40; %centroid (can use any marker: head, snout, centroid, etc.)
markers = [l_corner,r_corner,l_cup,r_cup,mouse,bl_corner];

%Set threshold DLC confidence for choice between snout and head tracking
thresh = 0.90;

%Set code to 1 to make ROI videos for each trial or 0 to not make
%videos(will run faster)
code = 1;

%% Gather video names and locations for analysis

p_folder = uigetdir('Y:\Data 2018-2019\Anterior Cingulate Cortex\BehaviorMiniscopesACC\Organized\');

logs = dir(fullfile(p_folder,'**','DLCcoordinates.csv'));
addpath(genpath('Y:\Lab Software and Code\ConnorStuff'));
logs = is_split(logs);
coord_idx = true(length(logs),1);

logs = logs(coord_idx);
numFiles = length(logs);

for i = [1:numFiles]
    
             s = regexp(logs(i).folder, '\', 'split');
            fprintf('Filtering matrix %.0f of %.0f: %s %s %s\n',i,numFiles,s{6},s{7},s{8})
            [NUM,~,~] = xlsread(fullfile(logs(i).folder,logs(i).name));
            load(fullfile(logs(i).folder,'timestamp.mat'));
            interactions = checkROI(NUM(:,markers), VideoReader(fullfile(logs(i).folder,'behavCam1.avi')), VideoWriter(fullfile(logs(i).folder,'behavCam1_ROI.avi')), thresh, timestamp.behavecam(:,3),code);
            save(fullfile(fullfile(logs(i).folder,'obj_interactions.mat')),'interactions')
            clear NUM;
end

%% Analyze videos
function interactions = checkROI(DLC, oldv, newv, thresh, time, code)

        %rearrange DLC columns so that X,Y are matlab friendly
        DLC = round(DLC);
        DLC = DLC(:,[2 1 3 5 4 6 8 7 9 11 10 12 14 13 15 17 16 18 20 19 21 22 23 24]);

        %create blank matrix to fill with behavior data
        interactions = zeros(length(DLC),8);
        time(1) = 0;

        %Set the chamber boundaries
        width = DLC(1,5) - DLC(1,2);
        wall = DLC(1,2) + DLC(22,23);
        
        %get Y coordinate to divide the chamber into 3 zones
        top = round(wall/3);
        bottom = round(wall/3)*2;

        %Create cup ROIs
        top_cup_diameter = DLC(1000,10) - DLC(1000,7);
        top_cup_center = [DLC(1000,7) + floor(top_cup_diameter*0.5), DLC(1000,8)];
        top_ROI = drawcircle('Center',top_cup_center,'Radius',floor((top_cup_diameter*1.5)/2),'StripeColor','red');

        bot_cup_diameter = DLC(1000,16) - DLC(1000,13);
        bot_cup_center = [DLC(1000,13) + floor(bot_cup_diameter*0.5), DLC(1000,14)];
        bot_ROI = drawcircle('Center',bot_cup_center,'Radius',floor((bot_cup_diameter*1.5)/2),'StripeColor','red');

        %Find distance conversion
        pix2meters = 0.445/width;

        %Check each frame
        for j = 1:length(DLC)
          
              mouse = DLC(j, 19:20);
                %true if mouse is in bottom zone
                if (mouse(1) >= bottom)
                interactions(j,6) = true;
                end
                %true if mouse is interacting with bottom cup
                if (inROI(bot_ROI, mouse(1), mouse(2)))
                interactions(j,2) = true;
                end
                % true if mouse is in middle 
                if (mouse(1) <= bottom && mouse(1) >= top)
                interactions(j,5) = true;
                end
                %true if mouse is in top
                if (mouse(1) <= top)
                interactions(j,4) = true;
                %true if mouse is interacting with top cup
                end
                if (inROI(top_ROI,mouse(1),mouse(2)))
                interactions(j,3) = true;
                end
            

            %Find distance traveled between points
            if (j == 1)
              last = mouse;
            else
              pixels_traveled = pdist2(mouse, last);
              interactions(j,7) = abs(pixels_traveled*pix2meters);
              interactions(j,8) = interactions(j,7)/abs((time(j) - time(j-1))*1000);
              last = mouse;
            end

            %Make videos if video code is 1
            if (code == 1)
              if (j == 1)
                  open(newv)
                  frame = readFrame(oldv);
                  [m,n] = size(frame(:,:,1));
              elseif (hasFrame(oldv))
                  frame = readFrame(oldv);

                  %mark the mouse
                  if ((mouse(1) > 4) && (mouse(1) < m-4 ))
                      if ((mouse(2) > 4) && (mouse(2) < n-4))
                          frame((mouse(1)-2):(mouse(1)+2),(mouse(2)-2):(mouse(2)+2),1) = 224;
                          frame((mouse(1)-2):(mouse(1)+2),(mouse(2)-2):(mouse(2)+2),2) = 163;
                          frame((mouse(1)-2):(mouse(1)+2),(mouse(2)-2):(mouse(2)+2),3) = 46;
                      end
                  end

                  %mark the boundaries
                  frame(top-2:top+2,:,1) = 175;
                  frame(top-2:top+2,:,2) = 54;
                  frame(top-2:top+2,:,3) = 60;

                  frame(bottom-2:bottom+2,:,1) = 175;
                  frame(bottom-2:bottom+2,:,2) = 54;
                  frame(bottom-2:bottom+2,:,3) = 60;

                  %mark the cup ROIs if the mouse is in them
                  if (interactions(j,3) == true)
                    Vertices = round(top_ROI.Vertices);
                    for k = 1:length(Vertices)
                        if ((Vertices(k,1) <= m)&&(Vertices(k,1) >= 1))
                            if ((Vertices(k,2) <= n)&&(Vertices(k,2) >= 1))
                                frame(Vertices(k,1),Vertices(k,2),1) = 175;
                                frame(Vertices(k,1),Vertices(k,2),2) = 54;
                                frame(Vertices(k,1),Vertices(k,2),3) = 60;
                            end
                        end
                    end
                  elseif (interactions(j,2) == true)
                      Vertices = round(bot_ROI.Vertices);
                      for k = 1:length(Vertices)
                            if ((Vertices(k,1) <= m)&&(Vertices(k,1) >= 1))
                                if ((Vertices(k,2) <= n)&&(Vertices(k,2) >= 1))
                                    frame(Vertices(k,1),Vertices(k,2),1) = 175;
                                    frame(Vertices(k,1),Vertices(k,2),2) = 54;
                                    frame(Vertices(k,1),Vertices(k,2),3) = 60;
                                end
                            end
                      end
                  end
                  writeVideo(newv, frame); 
              end
        end
    end
    close(newv);
end