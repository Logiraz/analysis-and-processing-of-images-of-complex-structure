function slope = getSlope(contourLabel, bergMap)
slope = zeros(max(contourLabel(:)), 1);
[xx, yy] = find(bergMap);
w = 7;
contourLabel(contourLabel == 0) = NaN;
for iP = 1 : numel(xx)
    iC = mode(contourLabel(max(xx(iP) - w, 1) : min(xx(iP) + w, sizeX), ...
                           max(yy(iP) - w, 1) : min(yy(iP) + w, sizeY)), "all");
    if ~isnan(iC)
        isBackground = contourLabel ~= iC;
        halfplain = getHalfplain(isBackground);
        slope(iC) = 1 - 2 * halfplain(xx(iP), yy(iP));
    end
end
end

