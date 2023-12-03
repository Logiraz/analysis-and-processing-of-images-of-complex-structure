function layers = extractLayers(image, colorMap)
R = image(:, : , 1);
G = image(:, : , 2);
B = image(:, : , 3);
[sizeX, sizeY] = size(R);
nClass = size(colorMap, 1);
layers = zeros(sizeX, sizeY, nClass, 'logical');
for iC = 1 : nClass
    layers(:, :, iC) = (R == colorMap(iC, 1)) & ...
                       (G == colorMap(iC, 2)) & ...
                       (B == colorMap(iC, 3));
end
end