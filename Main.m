close all
clear variables
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


    hBlobAnalysis = vision.BlobAnalysis('MinimumBlobArea' , 1, ...
        'MaximumBlobArea',5);
    [objArea, objCentroid,bboxOut] = step(hBlobAnalysis,sliderBW);


    Ishape = insertShape(image, 'rectangle',bboxOut,'Linewidth',4);

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
        % objects in each frame, and playing the video.
        obj.reader = VideoReader('StabilizedVideo.avi');

        obj.videoFWriter=vision.VideoFileWriter('result3.avi');
end