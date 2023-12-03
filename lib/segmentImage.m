function output = segmentImage(image, model)
switch class(model)
    case "network"
        nC = model.outputs{2}.size;
        windowSize = (model.inputs{1}.size / 3) ^ 0.5;
    case "ClassificationKNN"
        nC = numel(model.ClassNames);
        windowSize = (numel(model.PredictorNames) / 3) ^ 0.5;
    case "ClassificationTree"
        nC = numel(model.ClassNames);
        windowSize = (numel(model.PredictorNames) / 3) ^ 0.5;
    case "cell"
        if class(model{1}) == "ClassificationSVM"
            nC = numel(model);
            windowSize = (numel(model{1}.PredictorNames) / 3) ^ 0.5;
        end
end
[sizeX, sizeY] = size(image, [1, 2]);
input = zeros(3 * windowSize * windowSize, sizeX * sizeY, 'uint8');
mapPadded = padarray(image, [(windowSize - 1) / 2, (windowSize - 1) / 2, 0], 255);
for x = 1 : windowSize
    for y = 1 : windowSize
        mapShifted = mapPadded(x : x + sizeX - 1, y : y + sizeY - 1, :);
        mapShifted = permute(mapShifted, [3 2 1]);
        mapShifted = reshape(mapShifted, [3 sizeX * sizeY]);
        input((3 * (windowSize * x + y - windowSize) - 2) : (3 * (windowSize * x + y - windowSize)), :) = mapShifted;
    end
end
clear mapShifted mapPadded;

batch = 1 : 100000 : (sizeX * sizeY + 1);
batch(numel(batch)) = sizeX * sizeY + 1;
output = zeros(nC, sizeX * sizeY);
for i = 1 : numel(batch) - 1
    inputBatch = single(input(1 : 3 * windowSize * windowSize, batch(i) : batch(i + 1) - 1)) / 255;
    switch class(model)
        case "network"
            output(:, batch(i) : batch(i + 1) - 1) = sim(model, inputBatch);
        case "ClassificationKNN"
            tmp = predict(model, inputBatch');
            output(:, batch(i) : batch(i + 1) - 1) = full(ind2vec(tmp'));
        case "ClassificationTree"
            tmp = predict(model, inputBatch');
            output(:, batch(i) : batch(i + 1) - 1) = full(ind2vec(tmp'));
        case "cell"
            if class(model{1}) == "ClassificationSVM"
                for iC = 1 : nC
                    output(iC, batch(i) : batch(i + 1) - 1) = predict(model{iC}, inputBatch');
                end
            end
    end
end
output = uint8(output * 255);
output = reshape(output, [nC sizeY sizeX]);
output = permute(output, [3, 2, 1]);
end