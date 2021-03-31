videoReader = VideoReader('StabilizedVideo.avi');
videoPlayer = vision.VideoPlayer();
shapeInserter = vision.ShapeInserter('BorderColor','Custom', ...
    'CustomBorderColor',[1 0 0]);
objectFrame = readFrame(videoReader);
%figure;
%imshow(objectFrame);
%objectRegion=round(getPosition(imrect));
objectRegion=[686 532 11 4];
objectImage = insertShape(objectFrame,'Rectangle',objectRegion,'Color','red');
points = detectMinEigenFeatures(im2gray(objectFrame),'ROI',objectRegion);
pointImage = insertMarker(objectFrame,points.Location,'+','Color','white');
%figure;
%imshow(pointImage);
%title('Detected interest points');

objectHSV = rgb2hsv(objectFrame);

tracker = vision.HistogramBasedTracker;
initializeObject(tracker, objectHSV(:,:,1) , objectRegion);
while hasFrame(videoReader)
  frame = im2single(readFrame(videoReader));
  hsv = rgb2hsv(frame);
  bbox = tracker(hsv(:,:,1));

  out = shapeInserter(frame,bbox);
  videoPlayer(out);
end