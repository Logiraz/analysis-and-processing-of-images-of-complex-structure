function [lineMap, endPoint, dist] = oneInClusterGrouping(lineMap, cluster, endPoint)
[sizeX, sizeY] = size(lineMap);
limits = [10, 10; sizeX - 10, sizeY - 10];
ind = find([cluster.nEdge] == 1);

pairConnect = zeros(numel(ind), 2);
for iC = 1 : numel(ind)
    if checkLimits(endPoint(cluster(ind(iC)).edge(1)), limits) | ...
            checkLimits(endPoint(cluster(ind(iC)).edge(2)), limits)
        pairConnect(iC, :) = cluster(ind(iC)).edge;
    end
end
pairConnect(pairConnect(:, 1) == 0, :) = [];
lineMap = drawLines(lineMap, endPoint, pairConnect);
[endPoint, dist] = getEndPoints(lineMap, 1);
end