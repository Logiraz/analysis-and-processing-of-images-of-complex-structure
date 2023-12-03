function [digit, outputMap] = recognitionBrown(image, loc, alphaMap, windowSize, model0, model1, model2)
nC = model1.outputs{2}.size;
dphi = [-pi() / 2, pi() / 2];
[sizeX, sizeY] = size(image);

[xx, yy] = find(loc);
batch = 1 : min(100000, numel(xx) - 1) : numel(xx);
batch(end) = numel(xx) + 1;
outputMap = cell(2, 1);
measureMap = cell(2, 1);
outputMap{1} = zeros(sizeX, sizeY, "single");
measureMap{1} = zeros(sizeX, sizeY, "single");
outputMap{2} = zeros(sizeX, sizeY, "single");
measureMap{2} = zeros(sizeX, sizeY, "single");
outX = cell(2, 1);
outY = cell(2, 1);
outValue = cell(2, 1);
for iB = 1 : numel(batch) - 1
    xB = xx(batch(iB) : batch(iB + 1) - 1);
    yB = yy(batch(iB) : batch(iB + 1) - 1);
    phi = alphaMap(xB + sizeX * (yB - 1));

    % Распознавание первым каскадом с учётом двух направлений нормали
    for iType = 1 : 2
        input = getNbh(image, [xB, yB]', windowSize, phi + dphi(iType));
        isDig = sim(model0, input);
        switch class(model1)
            case "network"
                value = sim(model1, input);
                value = value .* isDig;
                value = value .* (value > 0.1);
                [digProb, dig] = max(value);
                outputMap{iType}(xB + sizeX * (yB - 1)) = dig .* (digProb > 0.2);
                measureMap{iType}(xB + sizeX * (yB - 1)) = digProb;
            case "ClassificationKNN"
                value = predict(model1, input')';
                value = value .* (isDig > 0.1);
                outputMap{iType}(xB + sizeX * (yB - 1)) = value;
                measureMap{iType}(xB + sizeX * (yB - 1)) = 1;
            case "ClassificationTree"
                value = predict(model1, input')';
                value = value .* (isDig > 0.1);
                outputMap{iType}(xB + sizeX * (yB - 1)) = value;
                measureMap{iType}(xB + sizeX * (yB - 1)) = 1;
            case "cell"
                if class(model1{1}) == "ClassificationSVM"
                    out = zeros(nC, size(input, 2), "single");
                    for iC = 1 : nC
                        [~, tmp] = predict(model1{iC}, input');
                        out(iC, :) = tmp(:, 2);
                    end
                    [~, value] = max(out);
                    value = value .* (isDig > 0.1);
                    outputMap{iType}(xB + sizeX * (yB - 1)) = value;
                    measureMap{iType}(xB + sizeX * (yB - 1)) = 1;
                end
        end
    end
end
outputMap{1}([1 : 5, sizeX - 4 : sizeX], :) = 0;
outputMap{1}(:, [1 : 5, sizeY - 4 : sizeY]) = 0;
outputMap{2}([1 : 5, sizeX - 4 : sizeX], :) = 0;
outputMap{2}(:, [1 : 5, sizeY - 4 : sizeY]) = 0;

for iType = 1 : 2
    % Фильтрация сегментов по размеру
    tempMap = zeros(sizeX, sizeY, "single");
    for iC = 1 : nC
        digitmap = outputMap{iType} == iC;
        digitmap = bwareaopen(digitmap, 5, 8);
        tempMap = tempMap + digitmap .* iC;
    end
    outputMap{iType} = tempMap;

    % фильтрация сросшихся вдоль главной оси сегментов
    [outLabel, nL] = bwlabel(outputMap{iType} > 0, 8);
    prop = regionprops(outLabel, 'MajorAxisLength', 'Centroid');
    for iL = 1 : nL
        mal = prop(iL).MajorAxisLength;
        if mal >= 8
            xx = round(prop(iL).Centroid(1));
            yy = round(prop(iL).Centroid(2));
            outputMap{iType}(yy - 1 : yy + 1, xx - 1 : xx + 1) = 0;
        end
    end

    % Распознавание вторым каскадом
    [outLabel, nL] = bwlabel(outputMap{iType} > 0, 8);
    prop = regionprops(outLabel, 'PixelIdxList');
    input = zeros(nC, nL);
    for iL = 1 : nL
        ind = prop(iL).PixelIdxList;
        temp = accumarray(outputMap{iType}(ind), measureMap{iType}(ind) .^ 0.5, [nC, 1]);
        input(:, iL) = temp;
        input(:, iL) = input(:, iL) / sum(input(:, iL));
    end
    switch class(model2)
        case "network"
            value = sim(model2, input);
            [pout, value] = max(value);
            value = value .* (pout > 0);
        case "ClassificationKNN"
            value = predict(model2, input')';
        case "ClassificationTree"
            value = predict(model2, input')';
        case "cell"
            if class(model2{1}) == "ClassificationSVM"
                out = zeros(nC, size(input, 2), "single");
                for iC = 1 : nC
                    [~, tmp] = predict(model2{iC}, input');
                    out(iC, :) = tmp(:, 2);
                end
                [~, value] = max(out);
            end
        otherwise
            [~, value] = max(input);
    end

    % Удаление ложных сегментов из суперсегмента
    for iL = 1 : nL
        ind = prop(iL).PixelIdxList;
        outputMap{iType}(ind) = outputMap{iType}(ind) .* (value(iL) == outputMap{iType}(ind));
    end
    [outX{iType}, outY{iType}, outValue{iType}] = getPropFromMap(outputMap{iType});
end
outValue{1} = outValue{1} - 1;
outValue{2} = outValue{2} - 1;
digit = cell(2, 1);
for iType = 1 : 2
    digit{iType} = struct('value', {outValue{iType}}, ...
                          'xx', {outX{iType}}, ...
                          'yy', {outY{iType}}, ...
                          'phi', {alphaMap(outX{iType} + sizeX * (outY{iType} - 1))});
end
end