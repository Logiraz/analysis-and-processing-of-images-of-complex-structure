function [lineMap, endPoint, dist] = relativeGrouping(lineMap, endPoint, dist, iteration)
nP = numel(endPoint);
ind = find([endPoint.onEdge] == 0);

nPair = 0;
pair = zeros(nP, 2);
flag = zeros(nP);
for iP = ind
    [~, iMinDist] = mink(dist(iP, :), 2);
    iFirst = iMinDist(1);
    iSecond = iMinDist(2);
    if (dist(iP, iSecond) > dist(iP, iFirst) + 20) && (dist(iP, iFirst) < 20 + 10 * iteration)
        [~, jMinDist] = mink(dist(iFirst, :), 2);
        jFirst = jMinDist(1);
        jSecond = jMinDist(2);
        if (dist(iFirst, jSecond) > dist(iFirst, jFirst) + 20) && (flag(iFirst, iP) == 0) && (jFirst == iP)
            nPair = nPair + 1;
            flag(iP, iFirst) = 1;
            pair(nPair, 1) = iP;
            pair(nPair, 2) = iFirst;
        end
    end
end
pair = pair(1 : nPair, :);

% Рисование линий-соединителей
% RGB = zeros([size(lineMap, 1), size(lineMap, 2), 3], "single");
% RGB(:, :, 1) = lineMap;
lineMap = drawLines(lineMap, endPoint, pair);
% RGB(:, :, 2) = lineMap;
% imtool(RGB);

[endPoint, dist] = getEndPoints(lineMap);
end