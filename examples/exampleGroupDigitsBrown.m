addpath(pwd + "\lib");
folderOut = "data\numbers\";
nMaps = 20;
load("data\indSplit.mat", "indTest");
load("models\ro_b.mat", "ro");
scaleStep = 10 * ones(nMaps, 1);
scaleStep(14 : end) = 5;

for iM = indTest
    disp(iM);
    load("data\digits\" + string(iM) + "_b.mat");
    [sizeX, sizeY] = size(outputMap{1});
    elevationMark = load("data\numbers\" + string(iM) + "_k.mat").cluster;
    elevationMark = [elevationMark.value] / 10;
    edgeMin = min(elevationMark) - 10;
    edgeMax = max(elevationMark) + 10;

    cluster = groupDigitsBrown(digit, [sizeX, sizeY], [edgeMin, edgeMax], ro, scaleStep(iM));
    save(folderOut + string(iM) + "_b.mat", "cluster");
end