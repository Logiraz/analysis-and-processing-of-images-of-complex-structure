function segmentation(folderIn, folderOut, file, model)
nFiles = numel(file);
chr = ["k", "b"];
iLayer = [1, 2];
for iF = 1 : nFiles
    disp(iF);
    image = imread(folderIn + file(iF));
    output = segmentImage(image, model);
    seg = output;
    save(folderOut + string(iF) + ".mat", "seg");
    for iType = 1 : numel(chr)
        seg = output(:, :, iLayer(iType));
        save(folderOut + string(iF) + chr(iType) + ".mat", "seg");
        imwrite(seg, folderOut + string(iF) + chr(iType) + ".png");
    end
end
end