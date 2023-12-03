addpath(pwd + "\lib");
folderOut = "data\numbers\";
nMaps = 20;
load("models\ro.mat", "ro");
for iM = 1 : nMaps
    disp(iM);
    load("data\digits\" + string(iM) + "_k.mat");
    cluster = clusterDigit(xx, yy, value);
    cluster = cluster([cluster.value] >= 1e2);
    cluster = clusterFilter(cluster, xx, yy, value, ro);
    cluster = semanticFilter(cluster);
    save(folderOut + string(iM) + "_k.mat", "cluster");
end