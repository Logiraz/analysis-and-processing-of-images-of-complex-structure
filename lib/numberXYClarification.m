function [xx, yy] = numberXYClarification(xx, yy, seg)
xxSaved = xx;
yySaved = yy;
[sizeX, sizeY] = size(seg);
wxOut = 20;
wyOut = 40;
tmpMap = seg(max(xx - wxOut, 1) : min(xx + wxOut, sizeX), ...
             max(yy - wyOut, 1) : min(yy + wyOut, sizeY));
xxCenter = min(xx, wxOut + 1);
yyCenter = min(yy, wyOut + 1);
wxIn = 15;
wyIn = 30;
tmpMap(max(xxCenter - wxIn, 1) : min(xxCenter + wxIn, sizeX), ...
       max(yyCenter - wyIn, 1) : min(yyCenter + wyIn, sizeY)) = 0;
tmpMap = imgaussfilt(tmpMap, 2, 'Padding', 0);
isLocMax = islocalmax(tmpMap);
[locxx, locyy] = find(isLocMax);
gmax = -1;
for iP = 1 : numel(locxx)
    if tmpMap(locxx(iP), locyy(iP)) > gmax
        gmax = tmpMap(locxx(iP), locyy(iP));
        xxMax = locxx(iP);
        yyMax = locyy(iP);
    end
end
if gmax > 0.6
    xx = xxSaved + xxMax - xxCenter;
    yy = yySaved + yyMax - yyCenter;
else
    xx = xxSaved;
    yy = yySaved;
end
end