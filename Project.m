videoReader = VideoReader('C:\Users\lisan\OneDrive\Documenten\Uni\Master\IPCV\Assignment\StabilizedVideo.avi');
videoPlayer = vision.VideoPlayer('Position', [100,100,680,520]);

objectFrame = readFrame(videoReader);
figure;
imshow(objectFrame);
objectRegion = [590,510,120,120];

objectImage = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red');
figure;
imshow(objectImage);
title('Red box shows object region');

points = detectMinEigenFeatures(im2gray(objectFrame),'ROI',objectRegion);

pointImage = insertMarker(objectFrame,points.Location,'+','Color','white');
figure;
imshow(pointImage);
title('Detected interest points');

tracker = vision.PointTracker('MaxBidirectionalError',1);

initialize(tracker,points.Location,objectFrame);

while hasFrame(videoReader)
      frame = readFrame(videoReader);
      [points,validity] = tracker(frame);
      out = insertMarker(frame,points(validity, :),'+');
      videoPlayer(out);
end

release(videoPlayer);