function [xx, yy, value, outputMap] = recognition(image, loc, windowSize, model0, model1, model2)
nC = model1.outputs{2}.size;
dNx = windowSize(1);
dNy = windowSize(2);
[sizeX, sizeY] = size(image);

% Распознавание первым каскадом
[xx, yy] = find(loc);
batch = 1 : min(100000, numel(xx) - 1) : numel(xx);
batch(end) = numel(xx) + 1;
outputMap = zeros(sizeX, sizeY, "single");
measureMap = zeros(sizeX, sizeY, "single");
for iB = 1 : numel(batch) - 1
    xB = xx(batch(iB) : batch(iB + 1) - 1);
    yB = yy(batch(iB) : batch(iB + 1) - 1);
    input = getNbh(image, [xB, yB]', [dNx, dNy], 0);
    isDig = sim(model0, input);

    switch class(model1)
        case "network"
            value = sim(model1, input);
            value = value .* isDig;
            value = value .* (value > 0.1);
            [digProb, dig] = max(value);
            outputMap(xB + sizeX * (yB - 1)) = dig .* (digProb > 0);
            measureMap(xB + sizeX * (yB - 1)) = digProb;
        case "ClassificationKNN"
            value = predict(model1, input')';
            value = value .* (isDig > 0.1);
            outputMap(xB + sizeX * (yB - 1)) = value;
            measureMap(xB + sizeX * (yB - 1)) = 1;
        case "ClassificationTree"
            value = predict(model1, input')';
            value = value .* (isDig > 0.1);
            outputMap(xB + sizeX * (yB - 1)) = value;
            measureMap(xB + sizeX * (yB - 1)) = 1;
        case "cell"
            if class(model1{1}) == "ClassificationSVM"
                out = zeros(nC, size(input, 2), "single");
                for iC = 1 : nC
                    [~, tmp] = predict(model1{iC}, input');
                    out(iC, :) = tmp(:, 2);
                end
                [~, value] = max(out);
                value = value .* (isDig > 0.1);
                outputMap(xB + sizeX * (yB - 1)) = value;
                measureMap(xB + sizeX * (yB - 1)) = 1;
            end
    end
end

% Удаление отметок по самым краям карты
outputMap([1 : 5, sizeX - 4 : sizeX], :) = 0;
outputMap(:, [1 : 5, sizeY - 4 : sizeY]) = 0;

% Фильтрация сегментов по размеру
tempMap = zeros(sizeX, sizeY, "single");
for iC = 1 : nC
    digitmap = outputMap == iC;
    if iC == 2
        digitmap = bwareaopen(digitmap, 7, 4) & ~bwareaopen(digitmap, 50, 4);
    else
        digitmap = bwareaopen(digitmap, 8, 4);
    end
    tempMap = tempMap + digitmap .* iC;
end
outputMap = tempMap;

% фильтрация сросшихся по горизонтали сегментов
[outLabel, nL] = bwlabel(outputMap > 0, 8);
prop = regionprops(outLabel, 'BoundingBox');
for iL = 1 : nL
    box = prop(iL).BoundingBox;
    if box(3) >= 10
        outputMap(floor(box(2)) : floor(box(2)) + box(4), floor(box(1)) + round(box(3) / 2)) = 0;
    end
end

% Заполнение ложно разрезанных сегментов кроме единиц
tempMap = zeros(sizeX, sizeY, "single");
for iC = 1 : nC
    digitmap = outputMap == iC;
    if iC ~= 2
        tempMap = tempMap + imclose(digitmap, strel("square", 3)) .* iC;
    else
        tempMap = tempMap + digitmap .* iC;
    end
end
outputMap = tempMap;
outputMap(outputMap > 10) = 0;

% Распознавание вторым каскадом
[outLabel, nL] = bwlabel(outputMap > 0, 8);
prop = regionprops(outLabel, 'PixelIdxList');
input = zeros(nC, nL);
for iL = 1 : nL
    ind = prop(iL).PixelIdxList;
    temp = accumarray(outputMap(ind), measureMap(ind), [nC, 1]);
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
    outputMap(ind) = outputMap(ind) .* (value(iL) == outputMap(ind));
end

% Фильтрация сегментов по размеру
tempMap = bwareaopen(outputMap > 0, 8, 8);
tempMap = tempMap & ~bwareaopen(outputMap > 0, 60, 8);
outputMap = outputMap .* tempMap;

% Фильтрация по наличию соседних сегментов
nhoodX = 7;
nhoodY = 49;
nhood = ones(nhoodX, nhoodY);
nhood(:, (nhoodY + 1) / 2 - 3 : (nhoodY + 1) / 2 + 3) = 0;
pointMap = zeros(sizeX, sizeY, "single");
[xx, yy, value] = getPropFromMap(outputMap);
pointMap(xx + sizeX * (yy - 1)) = value;
tempMap = imfilter(double(pointMap > 0), nhood);
outputMap = outputMap .* (tempMap > 0);
tempMap = bwareaopen(outputMap > 0, 8, 8);
outputMap = outputMap .* tempMap;
[xx, yy, value] = getPropFromMap(outputMap);

% Удаление вертикальных линий, которые похожи на единицы
ind = find(value == 2)';
indDel = value * 0;
for iL = ind
    if (xx(iL) > 15) && (xx(iL) < sizeX - 15)
        windowImage = image(xx(iL) - 15 : xx(iL) + 15, yy(iL) - 3 : yy(iL) + 3);
        wLine = sum(windowImage);
        if mean(wLine(4)) > 25
            indDel(iL) = 1;
        end
    end
end
xx = xx(~indDel);
yy = yy(~indDel);
value = value(~indDel);
outLabel = bwlabel(outputMap > 0, 8);
prop = regionprops(outLabel > 0, 'PixelIdxList');
for iL = find(indDel)'
    ind = prop(iL).PixelIdxList;
    outputMap(ind) = 0;
end
value = value - 1;
outputMap = single(outputMap);
end

%     Подбор границ интервала размеров сегментов для фильтрации
%     [outLabel, nL] = bwlabel(outputmap > 0, 8);
%     prop = regionprops(outLabel, 'Area');
%     outArea = [prop.Area];
%     targetmap = single(extractDigits(imread("data\rectrain\" + string(iP) + "k.png")) + 1);
%     [xT, yT] = find(targetmap > 0);
%     vT = targetmap(xT + sizeX * (yT - 1));
%     linkL = zeros(numel(vT), 1);
%     for iT = 1 : numel(vT)
%         [dr, dc] = find(outputmap(xT(iT) - 4 : xT(iT) + 4, yT(iT) - 4 : yT(iT) + 4) == vT(iT));
%         if numel(dr) > 0
%             linkL(iT) = outLabel(xT(iT) + dr(1) - 5, yT(iT) + dc(1) - 5);
%         end
%     end
%     linkL(linkL == 0) = [];
%     amin(iP) = min(outArea(linkL));
%     amax(iP) = max(outArea(linkL));
%     disp([min(amin(amin > 0)), max(amax)]);