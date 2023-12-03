function outputmap = extractDigits(image, colorMap)
R = image(:, : , 1);
G = image(:, : , 2);
B = image(:, : , 3);
[sizeX, sizeY] = size(R);
nClass = size(colorMap, 1);
outputmap = zeros(sizeX, sizeY) - 1;
for iC = 1 : nClass
    outputmap = outputmap +  ((R == colorMap(iC, 1)) & ...
                              (G == colorMap(iC, 2)) & ...
                              (B == colorMap(iC, 3))) .* iC;
end
end