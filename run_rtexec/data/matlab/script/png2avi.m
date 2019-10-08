function png2avi(dirname, avifile)
writerObj = VideoWriter(avifile);
open(writerObj);
files = dir(sprintf('%s/2*.png',dirname))
for file = files'
  thisimage = imread(fullfile(dirname,file.name));
  writeVideo(writerObj, thisimage);
end
close(writerObj);
