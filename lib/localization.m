function localization(folderIn, folderOut, file, chromosome)
nFiles = numel(file);
for iF = 1 : nFiles
    disp(iF);
    seg = imread(folderIn + file(iF));
    seg = single(seg) / 255;
    loc = applyChromosome(chromosome, seg);
    [~, filepart] = fileparts(file(iF));
    save(folderOut + filepart + ".mat", "loc");
    imwrite(loc, folderOut + file(iF));
end
end