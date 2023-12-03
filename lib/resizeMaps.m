function resizeMaps(folderIn, folderOut, files, scale)
nMaps = numel(files);
for iMap = 1 : nMaps
    image = imread(folderIn + files(iMap));
    image = imresize(image, scale(iMap), 'bicubic');
    imwrite(image, folderOut + files(iMap));
end
end