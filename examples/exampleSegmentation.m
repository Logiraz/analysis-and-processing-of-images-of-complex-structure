addpath(pwd + "\lib");
folderIn = "data\map\";
folderOut = "data\seg2\";
nMaps = 20;
files = string(1 : nMaps) + ".png";
load("models\seg\net_5_41.mat", "model");
segmentation(folderIn, folderOut, files, model);