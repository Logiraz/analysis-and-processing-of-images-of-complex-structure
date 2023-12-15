function f1 = getSegQuality(seg, label, colorMap)
rng(0);
nC = size(colorMap, 1);
layers = extractLayers(label, colorMap);
[sizeX, sizeY] = size(layers, [1, 2]);
target = layers(:, :, 1) * 0;
predicted = target * 0;
if any(layers(:) > 0)
    for iC = 1 : nC
        [xx, yy] = find(layers(:, :, iC));
        ind = randperm(numel(xx), min(numel(xx), 10000));
        target(xx(ind) + sizeX * (yy(ind) - 1)) = iC;
        temp = seg(xx(ind) + sizeX * (yy(ind) - 1) + sizeX * sizeY * (0 : nC - 1));
        [level, temp] = max(temp, [], 2);
        predicted(xx(ind) + sizeX * (yy(ind) - 1)) = temp .* (level > 255 * 0.25);
    end
end
precision = zeros(nC, 1);
recall = zeros(nC, 1);
f1 = zeros(nC, 1);
for iC = 1 : nC
    precision(iC) = sum((target == iC) & (predicted == iC)) / sum(predicted == iC);
    recall(iC) = sum((target == iC) & (predicted == iC)) / sum(target == iC);
    f1(iC) = 2 * precision(iC) * recall(iC) / (precision(iC) + recall(iC));
end
f1(isnan(f1)) = -1;
end