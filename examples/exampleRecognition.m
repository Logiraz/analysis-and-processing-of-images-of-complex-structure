addpath(pwd + "\lib");
folderOut = "data\digits\";
nMaps = 20;
windowSize = [19, 11];

isDigitModel = load("models\rec1\net_isDigit.mat").model;
recModel = load("models\rec1\net_9_105_k.mat").model;
rec2Model = load("models\rec2\knn2_1_k.mat").model;

for iM = 1 : nMaps
    disp(iM);
    seg = load("data\seg\" + string(iM) + "k.mat").seg;
    seg = single(seg) / 255;
    loc = load("data\loc\" + string(iM) + "k.mat").loc;
    [xx, yy, value, outputMap] = recognition(seg, loc, windowSize, isDigitModel, recModel, rec2Model);
    save(folderOut + string(iM) + "_k.mat", "xx", "yy", "value", "outputMap");
end