%Image processing Project Man Over Board Group 11
%Code for tracking and calculating distance of the buoy to the camera
%Lisanne Helmer, Timo Lempers, Indra Kumar
close all 
clear variables
%%
obj = setupSystemObjects();

i=0; %Initialises loop variable

writerObj = VideoWriter('myVideo2.avi'); %Will write results to file
writerObj.FrameRate = 25; %Initializes the frame rate of resulting video
open(writerObj);
Distance = 0; %Determines if a distance has already been found before or not

while hasFrame(obj.reader)
    image = readFrame(obj.reader);

    %Colored rectangles that act as a type of ROI limiting the range that
    %is being tracked
 image2 = insertShape(image,'FilledRectangle', [0 0 2000 523],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [0 0 655+i/2 2000],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [1062 0 500 2000],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [0 551 2000 700],'Color',{'green'});  
 I = image2;

 %Defined thresholds for Red
  channel1Min = 227.000;
channel1Max = 255.000;

%Defined thresholds for Green
channel2Min = 227.000;
channel2Max = 255.000;

%Defined thresholds for Blue
channel3Min = 227.000;
channel3Max = 255.000;

    % Applies thresholds to Image I
    sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
        (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
        (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);

    %Carries out blob analysis on objects between the range of 1 and 5
    %pixels with a maximum of 1 blob shown
    hBlobAnalysis = vision.BlobAnalysis('MinimumBlobArea' , 1, ...
        'MaximumBlobArea',5, 'MaximumCount', 1);
    [objArea, objCentroid,bboxOut] = step(hBlobAnalysis,sliderBW);
    
 %Checks whether there is an object being tracked
TF = isempty(bboxOut);

%If an object is being tracked, carry out loop
if TF == 0
    delta = (sqrt(0.98*2.5))/60; %Calcultes the value for delta
buoypos = bboxOut(1,2); %Calculates the Y value for the buoy
difference = buoypos-515; %Finds the difference between the buoy and the 
%Horizon line
focallength = 1.675213074929131e+03; %Found focallength through camera calibration
gamma = atand(double(difference)/focallength); %Caculates gamme value

beta = 90-gamma-delta; %Calculates beta value

R=6371000; %Radius of the earth in meters
h=2.5; %Height of Camera in meters
d = (R+h)*cosd(beta)-sqrt((R+h)^2*(cosd(beta)^2)-(R+h)^2+R^2); %Calculates distance 
%from camera to buoy
Distance = 1; %Sets a booleon to true for having detected an object in the frame
end

    Ishape = insertShape(image, 'rectangle',bboxOut,'Linewidth',4); %Displays
    %the bounding box of the buoy on the original video
    
if Distance == 0 %If no object has been tracked, display this fact
    Ishape = insertText(Ishape, [100 100],"No Buoy Found", 'FontSize', 24);
end

if Distance == 1 %If an object has been tracked, display its distance to the camera
    Ishape = insertText(Ishape, [100 100],d, 'FontSize', 24);

end
    release(hBlobAnalysis);%Releases the blob analysis
    imwrite(Ishape,strcat('image',int2str(i),'.png')); %Writes the current frames to a png
    frame=imread(strcat('image',int2str(i),'.png')); %Reads all the frames
    frame=im2frame(frame); %Converts RGB to video frame
    writeVideo(writerObj, frame); %Writes all the frames to a video file
    i=i+1; %Adds one to the loop value
end
close(writerObj); %Stops writing to file

function obj = setupSystemObjects()
        obj.reader = VideoReader('StabilizedVideo.avi'); %Initializes input video

end