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
    %image = (imread('C:\Timo Lempers\Masters\Image Processing\Project\project 2\blobAnalysis\examples\Screenshot.png')); %Reads the Image document
    %imshow(image);
 image2 = insertShape(image,'FilledRectangle', [0 0 2000 505],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [0 0 600 2000],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [1100 0 500 2000],'Color',{'green'});
 image2 = insertShape(image2,'FilledRectangle', [0 555 2000 500],'Color',{'green'});  
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

    [im, newOrigin] = undistortImage(image, cameraParams, 'OutputView', 'full');

    hBlobAnalysis = vision.BlobAnalysis('MinimumBlobArea' , 1, ...
        'MaximumBlobArea',5);
    [objArea, objCentroid,bboxOut] = step(hBlobAnalysis,sliderBW);


    Ishape = insertShape(image, 'rectangle',bboxOut,'Linewidth',4);
    
        % Detect the checkerboard.
    %[imagePoints, boardSize] = detectCheckerboardPoints(im);

    % Adjust the imagePoints so that they are expressed in the coordinate system
    % used in the original image, before it was undistorted.  This adjustment
    % makes it compatible with the cameraParameters object computed for the original image.
    %imagePoints = imagePoints + newOrigin; % adds newOrigin to every row of imagePoints
    %imagePoints=imagePoints(:,:,1);
    % Compute rotation and translation of the camera.
    [R, t] = extrinsics(imagePoints, worldPoints, cameraParams);
    % Compute the center of the first coin in the image.
    center1_image = bboxOut(1:2) + bboxOut(3:4)/2;

    % Convert to world coordinates.
    center1_world  = pointsToWorld(cameraParams, R, t, center1_image);

    % Remember to add the 0 z-coordinate.
    center1_world = [center1_world 0];

    % Compute the distance to the camera.
    [~, cameraLocation] = extrinsicsToCameraPose(R, t);
    distanceToCamera = norm(center1_world - cameraLocation);
    fprintf('Distance from the camera to the first penny = %0.2f mm\n', ...
        distanceToCamera);
        %figure
    %subplot(1,2,1)
    %imshow(Ishape)
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
        % objects in each frame, and playing the video.newOrigin
        obj.reader = VideoReader('StabilizedVideo.avi');

        obj.videoFWriter=vision.VideoFileWriter('result3.avi');
end

