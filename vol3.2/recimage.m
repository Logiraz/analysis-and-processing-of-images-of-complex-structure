function [xx, yy, output] = recimage(image, mask, nn0, nn1, nn2)
sizeX = size(image, 1);
sizeY = size(image, 2);
nC = 10;
[xx, yy] = find(mask);
points = [xx'; yy'];
input = getnbh(image, points, [13, 11], 0);

isdig = sim(nn0.Network, input);
output = sim(nn1.Network, input);
output = output .* isdig;
output = output .* (output > 0.1);
[pdig, dig] = max(output);
outputmap = zeros(sizeX, sizeY);
outputmap(xx + sizeX * (yy - 1)) = dig .* (pdig > 0);
measuremap = zeros(sizeX, sizeY);
measuremap(xx + sizeX * (yy - 1)) = pdig;
tempmap = zeros(sizeX, sizeY);
for ic = 1 : nC
    outlog = outputmap == ic;
    outlog = bwareaopen(outlog, 2, 4);
    tempmap = tempmap + outlog .* ic;
end
outputmap = tempmap;
clear xx yy input output pdig dig tempmap outlog;

outputmap = outputmap .* bwareaopen(outputmap > 0, 5, 8);
outputmap([1 : 5, sizeX - 4 : sizeX], :) = 0;
outputmap(:, [1 : 5, sizeY - 4 : sizeY]) = 0;
[outLabel, nL] = bwlabel(outputmap > 0, 8);
prop = regionprops(outLabel, 'BoundingBox', 'Area');
for il = 1 : nL
    if prop(il).Area > 28
        box = prop(il).BoundingBox;
        outputmap(floor(box(2)) : floor(box(2)) + box(4), floor(box(1)) + round(box(3) / 2)) = 0;
    end
end
clear outLabel nL prop box;

[outLabel, nL] = bwlabel(outputmap > 0, 8);
prop = regionprops(outLabel, 'Centroid', 'PixelIdxList', 'Area');
cnd = [prop.Centroid];
xx = floor(cnd(2 : 2 : end));
yy = floor(cnd(1 : 2 : end));
feature = zeros(nC, nL);
for il = 1 : nL
    ind = prop(il).PixelIdxList;
    temp = accumarray(outputmap(ind),  measuremap(ind), [nC, 1]);
    feature(:, il) = temp;
    feature(:, il) = feature(:, il) / sum(feature(:, il));
end
output = sim(nn2.Network, feature);
[pout, output] = max(output);
output = output .* (pout > 0);
end