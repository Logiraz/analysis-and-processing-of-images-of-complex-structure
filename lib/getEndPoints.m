function [endPoint, dist] = getEndPoints(lineMap, sameLabelOn)
arguments
    lineMap logical;
    sameLabelOn {mustBeReal} = 0;
end
[sizeX, sizeY] = size(lineMap);
endPointMap = bwmorph(lineMap, "endpoints");
label = bwlabel(lineMap);
[xx, yy] = find(endPointMap);
iL = label(xx + sizeX * (yy - 1));
[~, pos] = sort(iL);
xx = xx(pos);
yy = yy(pos);
iL = label(xx + sizeX * (yy - 1));
w = 10;
onEdge = (xx < w) | (xx > sizeX - w) | (yy < w) | (yy > sizeY - w);
endPoint = arrayfun(@(xx, yy, iL, onEdge) struct("xx", xx, "yy", yy, "iL", iL, "onEdge", onEdge), xx, yy, iL, onEdge);

dist = pdist2([xx yy], [xx yy]);
dist = single(dist);
nEP = numel(endPoint);

% Расстояние между концевыми точками, принадлежащим одному сегменту, считать бесконечным 
iP = 1 : (nEP / 2);
dist(2 * iP - 1 + nEP * (2 * iP - 2)) = Inf;
dist(2 * iP + nEP * (2 * iP - 1))     = Inf;
if ~sameLabelOn
    dist(2 * iP - 1 + nEP * (2 * iP - 1)) = Inf;
    dist(2 * iP + nEP * (2 * iP - 2))     = Inf;
end

% Расстояние до краевых точек считать бесконечным
dist(onEdge, :) = Inf;
dist(:, onEdge) = Inf;
end