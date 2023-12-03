function pair = getPairs(lineMap, endPoint, dist, roMax)
[sizeX, ~] = size(lineMap);
xx = [endPoint.xx];
yy = [endPoint.yy];

condition = dist < roMax;
condition = tril(condition);
pair = zeros(sum(condition, "all"), 2);
[pair(:, 1), pair(:, 2)] = find(condition);
nPair = size(pair, 1);
endPointMap = false(size(lineMap));
endPointMap(xx + sizeX * (yy - 1)) = true;
lineMapWide = lineMap & ~imdilate(endPointMap, strel('square', 5));
lineMapWide = imdilate(lineMapWide, strel('disk', 1));
w = 3;
for iP = 1 : nPair
    x1 = xx(pair(iP, 1));
    y1 = yy(pair(iP, 1));
    x2 = xx(pair(iP, 2));
    y2 = yy(pair(iP, 2));
    dX = abs(x1 - x2) + 1;
    dY = abs(y1 - y2) + 1;
    dMax = max(dX, dY);
    tempWindow = lineMapWide(min(x1, x2) - w : max(x1, x2) + w, min(y1, y2) - w : max(y1, y2) + w);
    if dX > 1 && dY > 1
        tempLine = false(dX, dY);
        tempLine(ceil(dX / dMax : dX / dMax : dX) + dX * ceil((dY / dMax : dY / dMax : dY) - 1)) = true;
        if (x1 - x2) * (y1 - y2) < 0
            tempLine = flip(tempLine);
        end
    else
        if dX > 1
            tempLine = ones(dX, 1);
        end
        if dY > 1
            tempLine = ones(1, dY);
        end
    end
    line = zeros(dX + 2 * w, dY + 2 * w);
    line(w + (1 : dX), w + (1 : dY)) = tempLine;
    if any(tempWindow & line, "all")
        pair(iP, :) = [-1 -1];
    end
end
pair(pair(:, 1) < 0, :) = [];
end