function lineMap = drawLines(lineMap, endPoint, pair, isSafe)
arguments
    lineMap logical;
    endPoint;
    pair;
    isSafe = false;
end
xx = [endPoint.xx];
yy = [endPoint.yy];

% Расчёт, пересекаются ли какие-то пары отрезков, тогда их удаляем из рассмотрения
x1 = xx(pair(:, 1));
y1 = yy(pair(:, 1));
x2 = xx(pair(:, 2));
y2 = yy(pair(:, 2));
t1 = ((y2' - y1') .* (x1 -  x1') - (y1 -  y1') .* (x2' - x1')) ./ ...
     ((y2  - y1)  .* (x2' - x1') - (y2' - y1') .* (x2 -  x1));
t2 = (t1 .* (x2 - x1) + x1 - x1') ./ (x2' - x1');
condition = (t1 > 0) & (t1 < 1) & (t2 > 0) & (t2 < 1);
condition = tril(condition);
[indPair1, indPair2] = find(condition);
pair(union(indPair1, indPair2), :) = [];

nPair = size(pair, 1);
for iP = 1 : nPair
    x1 = xx(pair(iP, 1));
    y1 = yy(pair(iP, 1));
    x2 = xx(pair(iP, 2));
    y2 = yy(pair(iP, 2));
    dX = abs(x1 - x2) + 1;
    dY = abs(y1 - y2) + 1;
    dMax = max(dX, dY);
    if dX > 1 && dY > 1
        line = false(dX, dY);
        line(ceil(dX / dMax : dX / dMax : dX) + dX * ceil((dY / dMax : dY / dMax : dY) - 1)) = true;
        if (x1 - x2) * (y1 - y2) < 0
            line = flip(line);
        end
        lineMap(min(x1, x2) : max(x1, x2), min(y1, y2) : max(y1, y2)) = lineMap(min(x1, x2) : max(x1, x2), min(y1, y2) : max(y1, y2)) | line;
    else
        if dX > 1
            lineMap(min(x1, x2) : max(x1, x2), y1) = ones(dX, 1);
        end
        if dY > 1
            lineMap(x1, min(y1, y2) : max(y1, y2)) = ones(1, dY);
        end
    end
end
lineMap = bwmorph(lineMap, 'skel', Inf);
if ~isSafe
    lineMap = lineMap &~ imdilate(bwmorph(lineMap, 'branchpoints'), strel("square", 5));
end
lineMap = bwareaopen(lineMap, 5);
end