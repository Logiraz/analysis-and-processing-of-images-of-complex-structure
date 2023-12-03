function alphaMap = discreteTangent(lineMap)
[sizeX, sizeY] = size(lineMap);
lineProp = regionprops(lineMap, "PixelList");
alphaMap = zeros(sizeX, sizeY);
for iL = 1 : numel(lineProp)
    xx = lineProp(iL).PixelList(:, 2);
    yy = lineProp(iL).PixelList(:, 1);
    if numel(xx) > 100
        trace = bwtraceboundary(lineMap, [xx(round(numel(xx) / 2)), yy(round(numel(xx) / 2))], "W");
        if size(trace, 1) == numel(xx) + 1
            xx = trace(:, 1);
            yy = trace(:, 2);
        else
            ind = find(abs(trace(3 : end, 1) - trace(1 : end - 2, 1)) + abs(trace(3 : end, 2) - trace(1 : end - 2, 2)) == 0);
            ind = ind + 1;
            if numel(ind) == 2
                xx = trace(ind(1) : ind(2), 1);
                yy = trace(ind(1) : ind(2), 2);
            else
                xx = trace(1 : ind, 1);
                yy = trace(1 : ind, 2);
            end
        end
        ro = cumsum([0; (diff(xx) .^ 2 + diff(yy) .^ 2) .^ 0.5]);
        splineX = spline(ro(1 : 10 : end), xx(1 : 10 : end));
        splineY = spline(ro(1 : 10 : end), yy(1 : 10 : end));
        alphaMap(xx + sizeX * (yy - 1)) = atan2(ppval(fnder(splineX), ro), ppval(fnder(splineY), ro));
    end
end

w = 3;
[xx, yy] = find(lineMap);
sumCos = zeros(sizeX, sizeY);
sumSin = zeros(sizeX, sizeY);
counter = zeros(sizeX, sizeY);
for iP = 1 : numel(xx)
    ind = xx(iP) + (-w : w) + sizeX * (yy(iP) - 1 + (-w : w)');
    ind = ind(:);
    ind(ind < 1) = [];
    ind(ind > sizeX * sizeY) = [];
    sumCos(ind) = sumCos(ind) + cos(alphaMap(xx(iP), yy(iP)));
    sumSin(ind) = sumSin(ind) + sin(alphaMap(xx(iP), yy(iP)));
    counter(ind) = counter(ind) + 1;
end
alphaMap = atan2(sumCos ./ counter, sumSin ./ counter);
end