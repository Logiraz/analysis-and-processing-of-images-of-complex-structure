addpath(pwd + "\lib");
folderOut = "data\digits\";
nMaps = 20;
windowSize = [17, 11];
load("data\indSplit.mat");

isDigitModel = load("models\rec1\net_isDigit_b.mat").model;
recModel = load("models\rec1\net_9_187_bm.mat").model;
rec2Model = load("models\rec2\knn2_1_k.mat").model;

for iM = indTest
    disp(iM);
    seg = load("data\seg\" + string(iM) + "b.mat").seg;
    seg = single(seg) / 255;
    loc = load("data\loc\" + string(iM) + "b.mat").loc;
    lineMap = imread("data\loc_line\3_\" + string(iM) + "f.png");
    if class(lineMap) == "uint8"
        lineMap = lineMap(:, :, 1) > 128;
    end
    loc = loc & imdilate(lineMap, strel("square", 3));
    lineMap = bwskel(lineMap);
    alphaMap = discreteTangent(lineMap);
    
    [digit, outputMap] = recognitionBrown(seg, loc, alphaMap, windowSize, isDigitModel, recModel, rec2Model);
    save(folderOut + string(iM) + "_b.mat", "digit", "outputMap");
end