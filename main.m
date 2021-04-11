close all;

numImages = 26;
files = cell(1, numImages);
val=1;
for i = 1:numImages
    files{i} = fullfile(sprintf('MV_f2.8_100_%d.jpg', val));
    val=val+23;
end

% Display one of the calibration images
magnification = 25;
I = imread(files{1});
figure; imshow(I, 'InitialMagnification', magnification);
title('One of the Calibration Images');

% Detect the checkerboard corners in the images.
[imagePoints, boardSize] = detectCheckerboardPoints(files);

% Generate the world coordinates of the checkerboard corners in the
% pattern-centric coordinate system, with the upper-left corner at (0,0).
squareSize = 40; % in millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
imageSize = [size(I, 1), size(I, 2)];
cameraParams = estimateCameraParameters(imagePoints, worldPoints, ...
                                     'ImageSize', imageSize);
                                 
%%
obj = setupSystemObjects();

%videoplayer=vision.VideoPlayer('Position', [20, 400, 700, 400]);
i=0;

writerObj = VideoWriter('myVideo2.avi');
writerObj.FrameRate = 25;
open(writerObj);

while hasFrame(obj.reader)
    image = readFrame(obj.reader);
    %image = (  imread('C:\Timo Lempers\Masters\Image Processing\Project\project 2\blobAnalysis\examples\Screenshot.png')); %Reads the Image document
    %imshow(image);
 image2 = insertShape(image,'FilledRectangle', [0 0 2000 505],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [0 0 600 2000],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [1100 0 500 2000],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [0 555 2000 700],'Color',{'green'});  
 I = image2;

   channel1Min = 226.000;
channel1Max = 255.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 227.000;
channel2Max = 255.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 227.000;
channel3Max = 255.000;

    % Create mask based on chosen histogram thresholds
    sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
        (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
        (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);

    %subplot(1,3,2)
    %imshow(sliderBW)

 %[im, newOrigin] = undistortImage(image2, cameraParams, 'OutputView', 'full');

    hBlobAnalysis = vision.BlobAnalysis('MinimumBlobArea' , 1, ...
        'MaximumBlobArea',5);
    [objArea, objCentroid,bboxOut] = step(hBlobAnalysis,sliderBW);


    Ishape = insertShape(image2, 'rectangle',bboxOut,'Linewidth',4);
    delta = (sqrt(0.98*8.2))/60;  

if isempty(bboxOut)==0
focallength = 1.675213074929131e+03;
buoy_dist=abs(515-bboxOut(2));
gamma = atand(double(buoy_dist)/focallength);

beta = 90-gamma-delta;

R=6371000;
h=2.5;
d = (R+2.5)*cosd(beta)-sqrt((R+h)^2*(cosd(beta)^2)-(R+h)^2+R^2);
     fprintf('Distance from the camera to the buoy = %0.2f m\n', ...
        d);
end
    release(hBlobAnalysis);
    imwrite(Ishape,strcat('image',int2str(i),'.png'));
    frame=imread(strcat('image',int2str(i),'.png'));
    frame=im2frame(frame);
    writeVideo(writerObj, frame);
    %delete(Ishape,strcat('image',int2str(i),'.png'))
    i=i+1;
end
close(writerObj);

function obj = setupSystemObjects()
        % Initialize Video I/O
        % Create objects for reading a video from a file, drawing the tracked
        % objects in each frame, and playing the video.
        obj.reader = VideoReader('StabilizedVideo.avi');

        obj.videoFWriter=vision.VideoFileWriter('result3.avi');
end
