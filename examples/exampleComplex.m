addpath(pwd + "\lib");
load("data\indSplit.mat", "indTest");
nMaps = 20;
scaleStep = [10 * ones(1, 13), 5 * ones(1, 7)];

for iM = indTest(1)
    lineMap = imread("data\loc_line\4\" + string(iM) + "f.png");
    if class(lineMap) == "uint8"
        lineMap = lineMap(:, :, 1) > 128;
    end
    [sizeX, sizeY] = size(lineMap);
    halflineMap = imread("data\loc_line\4\" + string(iM) + "h.png");
    if class(halflineMap) == "uint8"
        halflineMap = halflineMap(:, :, 1) > 128;
    end
    lineMap = lineMap & ~halflineMap;
    [contourLabel, contourN] = bwlabel(lineMap);

    % Определение скатов
    bergMap = imread("data\loc_line\4\" + string(iM) + "b.png");
    bergMap = (bergMap(:, :, 1) > 128) & (bergMap(:, :, 2) < 128);
    bergMap = imerode(bergMap, strel("square", 3));
    slope = getSlope(contourLabel, bergMap);

    % Получение графа связности и мест, в которых должны быть экстремумы
    contourGraph = graph();
    [backgroundLabel, backgroundN] = bwlabel(contourLabel == 0, 4);
    isExtremum = false(sizeX, sizeY);
    for iB = 1 : backgroundN
        dilatedBackground = imdilate(backgroundLabel == iB, strel('square', 3));
        nearContour = setdiff(unique(contourLabel(dilatedBackground)), 0);
        if numel(nearContour) > 1
            for i = 1 : numel(nearContour) - 1
                for j =  i + 1 : numel(nearContour)
                    contourGraph = addedge(contourGraph, nearContour(i), nearContour(j));
                end
            end
        else
            [xx, yy] = find(contourLabel == nearContour);
            xx = round(mean(xx));
            yy = round(mean(yy));
            isExtremum(xx, yy) = true;
        end
    end

    % Алгоритм комплексного анализа
    rng(0);
    relativeElevation = ones(contourN, 1) * Inf;
    colorState = zeros(contourN, 1);
    counter = contourN;
    ind = find(slope ~= 0);
    rootNode = ind(ceil(rand() * numel(ind)));
    colorState(rootNode) = 1;
    relativeElevation(rootNode) = 0;
    initSlope = slope;
    while counter > 0
        indi = find(colorState == 1);
        if isempty(indi)
            indi = [];
        end
        for i = indi'
            isBackground = contourLabel ~= i;
            halfplaini = getHalfplain(isBackground);
            adjNode = neighbors(contourGraph, i);
            indj = adjNode .* (colorState(adjNode) == 0);
            indj(indj == 0) = [];
            if isempty(indj)
                indj = [];
            end
            for j = indj'
                isBackground = contourLabel ~= j;
                halfplainj = getHalfplain(isBackground);
                if initSlope(j) ~= 0
                    dilatedHPi = imdilate(halfplaini, strel('disk', 2));
                    dilatedHPi = dilatedHPi & ~halfplaini;
                    bgdi = unique(backgroundLabel(dilatedHPi)); bgdi(bgdi == 0) = [];

                    erodedHPi =  imerode(halfplaini, strel('disk', 2));
                    erodedHPi = halfplaini & ~erodedHPi;
                    bgei = unique(backgroundLabel(erodedHPi)); bgei(bgei == 0) = [];

                    dilatedHPj = imdilate(halfplainj, strel('disk', 2));
                    dilatedHPj = dilatedHPj & ~halfplainj;
                    bgdj = unique(backgroundLabel(dilatedHPj)); bgdj(bgdj == 0) = [];

                    erodedHPj =  imerode(halfplainj, strel('disk', 2));
                    erodedHPj = halfplainj & ~erodedHPj;
                    bgej = unique(backgroundLabel(erodedHPj)); bgej(bgej == 0) = [];

                    if slope(i) == -slope(j)
                        relativeElevation(j) = relativeElevation(i) + ...
                            ((numel(intersect(bgei, bgej)) > 0) - ...
                            (numel(intersect(bgdi, bgdj)) > 0)) * slope(i) * scaleStep(iM);
                    end
                    if slope(i) == slope(j)
                        relativeElevation(j) = relativeElevation(i) + ...
                            ((numel(intersect(bgei, bgdj)) > 0) - ...
                            (numel(intersect(bgdi, bgej)) > 0)) * slope(i) * scaleStep(iM);
                    end
                else
                    tmp = (contourLabel == j) .* halfplaini;
                    if sum(tmp, "all") > 0
                        relativeElevation(j) = relativeElevation(i) + slope(i) * scaleStep(iM);
                    else
                        relativeElevation(j) = relativeElevation(i) - slope(i) * scaleStep(iM);
                    end
                    tmp = halfplainj .* halfplaini;
                    if sum(tmp, "all") > 0
                        slope(j) = slope(i);
                    else
                        slope(j) = -slope(i);
                    end
                end
                colorState(j) = 1;
            end
            colorState(i) = -1;
            counter = counter - 1;
        end
    end

    % Привязка распознанных подписей горизонталей и их корректировка
    numberBrown = load("data\numbers\" + string(iM) + "_b.mat").cluster;
    recognizedElevation = ones(contourN, 1) * Inf;
    tmpMap = contourLabel;
    tmpMap(tmpMap == 0) = NaN;
    w = 5;
    for iC = 1 : numel(numberBrown)
        xx = numberBrown(iC).xx;
        yy = numberBrown(iC).yy;
        nearContour = mode(tmpMap(max(xx - w, 1) : min(xx + w, sizeX), ...
                                  max(yy - w, 1) : min(yy + w, sizeY)), "all");
        if ~isnan(nearContour)
            recognizedElevation(nearContour) = numberBrown(iC).value;
        end
    end
    ind = find(~isinf(recognizedElevation));
    elevation = zeros(contourN, 1);
    if numel(ind) > 0
        rootElevation = recognizedElevation(ind) - relativeElevation(ind);
        elevation = mode(rootElevation) + relativeElevation;
    end
    clear tmpMap;

    % Привязка распознанных отметок высот и их корректировка
    numberBlack = load("data\numbers\" + string(iM) + "_k.mat").cluster;
    load("data\seg\" + string(iM) + "k.mat", 'seg');
    seg = single(seg) / 255;
    w = 60;
    for iC = 1 : numel(numberBlack)
        xx = numberBlack(iC).xx;
        yy = numberBlack(iC).yy;
        [xx, yy] = numberXYClarification(xx, yy, seg);
        numberBlack(iC).xx = xx;
        numberBlack(iC).yy = yy;
        iB = backgroundLabel(xx, yy);
        dilatedBackground = imdilate(backgroundLabel == iB, strel('square', 5));
        nearContour = setdiff(unique(contourLabel(dilatedBackground)), 0);
        [dX, dY] = find(isExtremum(max(xx - w, 1) : min(xx + w, sizeX), ...
                                   max(yy - w, 1) : min(yy + w, sizeY)));
        if numel(dX) == 0
            if numel(nearContour) > 1
                if mod(numberBlack(iC).value, 100) > 0
                    numberBlack(iC).value = min(elevation(nearContour)) + mod(numberBlack(iC).value, 100) / 10;
                else
                    numberBlack(iC).value = numberBlack(iC).value / 10;
                end
            else
                if slope(nearContour) == 1
                    if mod(numberBlack(iC).value, 100) > 0
                        numberBlack(iC).value = elevation(nearContour) + mod(numberBlack(iC).value, 100) / 10;;
                    else
                        numberBlack(iC).value = numberBlack(iC).value / 10;
                    end
                else
                    numberBlack(iC).value = elevation(nearContour) - scaleStep(iM) + ...
                                            mod(numberBlack(iC).value, 100) / 10;
                end
            end
        else
            cx = min(xx, w + 1);
            cy = min(yy, w + 1);
            [~, i] = min((dX - cx) .^ 2 + (dY - cy) .^ 2);
            numberBlack(iC).xx = xx + dX(i) - cx;
            numberBlack(iC).yy = yy + dY(i) - cy;
            xx = numberBlack(iC).xx;
            yy = numberBlack(iC).yy;
            dilatedBackground = imdilate(backgroundLabel == backgroundLabel(xx, yy), strel('square', 5));
            nearContour = setdiff(unique(contourLabel(dilatedBackground)), 0);
            if slope(nearContour) == 1
                numberBlack(iC).value = elevation(nearContour) + mod(numberBlack(iC).value, 100) / 10;
            else
                numberBlack(iC).value = elevation(nearContour) - scaleStep(iM) + ...
                                        mod(numberBlack(iC).value, 100) / 10;
            end
        end
    end

    % Привязка полугоризонталей
    [halfcontourLabel, halfcontourN] = bwlabel(halflineMap);
    halfelevation = zeros(halfcontourN, 1);
    for iC = 1 : halfcontourN
        iB = backgroundLabel(halfcontourLabel == iC);
        iB = iB(1);
        dilatedBackground = imdilate(backgroundLabel == iB, strel('square', 5));
        nearContour = setdiff(unique(contourLabel(dilatedBackground)), 0);
        if numel(nearContour) > 1
            halfelevation(iC) = min(elevation(nearContour)) + scaleStep(iM) / 2;
        else
            isBackground = contourLabel ~= nearContour;
            halfplain = getHalfplain(isBackground);
            [xx, yy] = find(halfcontourLabel == iC);
            if halfplain(xx(1), yy(1))
                halfelevation(iC) = elevation(nearContour) - slope(nearContour) * scaleStep(iM) + ...
                                    scaleStep(iM) / 2;
            else
                halfelevation(iC) = elevation(nearContour) + slope(nearContour) * scaleStep(iM) + ...
                                    scaleStep(iM) / 2;
            end
        end
    end
    save("data\complex\" + string(iM) + ".mat", ...
        "contourLabel", "elevation", "halfcontourLabel", "halfelevation", "numberBlack");
end