function [xx, yy, value] = getPropFromMap(map)
outputL = bwlabel(map > 0, 8);
prop = regionprops(outputL > 0, 'Centroid', 'PixelIdxList');
cnd = [prop.Centroid];
xx = floor(cnd(2 : 2 : end));
yy = floor(cnd(1 : 2 : end));
value = map(arrayfun(@(S) S.PixelIdxList(1), prop));
end