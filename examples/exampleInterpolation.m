addpath(pwd + "\lib");
load("data\indSplit.mat", "indTest");
nMaps = 20;
scaleStep = [10 * ones(1, 13), 5 * ones(1, 7)];
P = 0.2;
nPoints = 3;

for iM = indTest(1)
    disp(iM);
    tic
    load("data\complex\" + string(iM) + ".mat");
    [sizeX, sizeY] = size(contourLabel);
    elevationMap = zeros(sizeX, sizeY);
    for iC = 1 : numel(elevation)
        elevationMap = elevationMap + elevation(iC) * (contourLabel == iC);
    end
    for iC = 1 : numel(halfelevation)
        elevationMap = elevationMap + halfelevation(iC) * (halfcontourLabel == iC);
    end
    elevationMap([numberBlack.xx] + sizeX * ([numberBlack.yy] - 1)) = [numberBlack.value];
    isPoint = false(sizeX, sizeY);
    isPoint([numberBlack.xx] + sizeX * ([numberBlack.yy] - 1)) = true;

    isContour = contourLabel > 0;
    [backgroundLabel, backgroundN] = bwlabel(~isContour, 4);
    isProcessed = false(backgroundN, 1);
    se = strel('square', 3);
    dem = elevationMap;
    for iB = 1 : backgroundN
        isBackground = backgroundLabel == iB;
        backgroundEdge = imdilate(isBackground, se) & ~isBackground;
        edgeElevation = backgroundEdge .* elevationMap;
        allElevations = elevationMap(backgroundEdge);
        allElevations(allElevations == 0) = [];
        firstElevation = mode(allElevations);
        allElevations(allElevations == firstElevation) = [];
        secondElevation = mode(allElevations);

        % Если найдено 2 горизонтали, то интерполируем по значению между ними
        if ~isnan(secondElevation)
            isProcessed(iB) = true;
            [firstX, firstY] = find(edgeElevation == firstElevation);
            if numel(firstX) > 30
                ind = rand([numel(firstX) 1]) > P;
                firstX(ind) = [];
                firstY(ind) = [];
            end
            [secondX, secondY] = find(edgeElevation == secondElevation);
            if numel(secondX) > 30
                ind = rand([numel(secondX) 1]) > P;
                secondX(ind) = [];
                secondY(ind) = [];
            end
            [xx, yy] = find(isBackground);
            distsToFirst =  pdist2([firstX firstY], [xx yy], 'euclidean', 'Smallest', nPoints);
            distsToSecond = pdist2([secondX secondY], [xx yy], 'euclidean', 'Smallest', nPoints);
            minDistToFirst =  distsToFirst(1, :);
            minDistToSecond = distsToSecond(1, :);
            isFirstNearer = minDistToFirst < minDistToSecond;
            distsToFirst(:, ~isFirstNearer) = repmat(minDistToFirst(~isFirstNearer), ...
                [min(nPoints, size(distsToFirst, 1)) 1]);
            distsToSecond(:, isFirstNearer) = repmat(minDistToSecond(isFirstNearer), ...
                [min(nPoints, size(distsToSecond, 1)) 1]);
            firstWeight = sum(1 ./ distsToFirst, 1);
            secondWeight = sum(1 ./ distsToSecond, 1);
            [extremumX, extremumY] = find(isPoint & isBackground);
            if numel(extremumX) > 0
                [minDistToExtremum, iExtremum] = pdist2([extremumX extremumY], [xx yy], 'euclidean', 'Smallest', 1);
                extremumWeight = 1 ./ (minDistToExtremum + 1e-2) * nPoints;
                extremumElevation = elevationMap(extremumX(iExtremum) + sizeX * (extremumY(iExtremum) - 1));
                extremumElevation = reshape(extremumElevation, [1, numel(extremumElevation)]);
                dem(xx + sizeX * (yy - 1)) = (firstElevation * firstWeight + ...
                    secondElevation * secondWeight + extremumElevation .* extremumWeight) ./ ...
                    (firstWeight + secondWeight + extremumWeight);
            else
                dem(xx + sizeX * (yy - 1)) = (firstElevation * firstWeight + secondElevation * secondWeight) ./ ...
                    (firstWeight + secondWeight);
            end
        end
    end

    % Если найдена только одна, то интерполируем к экстремуму или экстраполируем к границе
    [gradX, gradY] = gradient(dem);
    for iB = find(~isProcessed)'
        isBackground = backgroundLabel == iB;
        backgroundEdge = imdilate(isBackground, se) & ~isBackground;
        edgeElevation = backgroundEdge .* elevationMap;
        allElevations = elevationMap(backgroundEdge);
        allElevations(allElevations == 0) = [];
        firstElevation = mode(allElevations);
        allElevations(allElevations == firstElevation) = [];
        secondElevation = mode(allElevations);
        if isnan(secondElevation)
            % Обработка экстремумов
            if sum(isBackground & isPoint, "all") > 0
                [xx, yy] = find(isBackground);
                [firstX, firstY] = find(edgeElevation == firstElevation);
                distsToFirst =  pdist2([firstX firstY], [xx yy], 'euclidean', 'Smallest', nPoints);
                firstWeight = sum(1 ./ distsToFirst, 1);
                [extremumX, extremumY] = find(isPoint & isBackground);
                [minDistToExtremum, iExtremum] = pdist2([extremumX extremumY], [xx yy], 'euclidean', 'Smallest', 1);
                extremumWeight = 1 ./ (minDistToExtremum + 1e-2) * nPoints;
                extremumElevation = elevationMap(extremumX(iExtremum) + sizeX * (extremumY(iExtremum) - 1));
                extremumElevation = reshape(extremumElevation, [1, numel(extremumElevation)]);
                dem(xx + sizeX * (yy- 1)) = (firstElevation * firstWeight + extremumElevation .* extremumWeight) ./ ...
                                                             (firstWeight + extremumWeight);
            % Обработка границ
            else
                backgroundEdge = imdilate(isBackground, strel('square', 5)) & ~backgroundEdge & ~isBackground;
                [firstX, firstY] = find(backgroundEdge);
                ind = (firstX <= 2) | (firstY <= 2) | (firstX >= sizeX - 1) | (firstY >= sizeY - 1);
                firstX(ind) = [];
                firstY(ind) = [];
                centroidX = mean(firstX, "all");
                centroidY = mean(firstY, "all");
                secondElevation = firstElevation + ...
                    sum(gradX(firstX + sizeX * (firstY - 1)) .* (centroidY - firstY) + ...
                        gradY(firstX + sizeX * (firstY - 1)) .* (centroidX - firstX)) / (2 * numel(firstX));
                if (secondElevation > firstElevation + scaleStep(iM))
                    secondElevation = firstElevation + 0.5 * scaleStep(iM);
                end
                if (secondElevation < firstElevation - scaleStep(iM))
                    secondElevation = firstElevation - 0.5 * scaleStep(iM);
                end
                [firstX, firstY] = find(edgeElevation == firstElevation);
                [xx, yy] = find(isBackground);
                weight = pdist2([centroidX centroidY], [xx yy], 'euclidean') ./ ...
                         pdist2([firstX firstY], [xx yy], 'euclidean', 'Smallest', 1) / nPoints;
                dem(xx + sizeX * (yy - 1)) = (firstElevation * weight + secondElevation) ./ (weight + 1);
            end
        end
    end
    h = fspecial('gaussian', 5, 5);
    dem = imfilter(dem, h, 'replicate');
    save("data\complex\" + string(iM) + "_dem.mat", "dem");
end

% Визуализация
% stx = 1000;
% sty = 1000;
% [xx, yy] = meshgrid(1 : stx, 1 : sty);
% xx = xx';
% yy = yy';
% zz = demMy(1 : stx, 1 : sty);
% map = imread("data\map\" + string(iM) + ".png");
% pixToMeters = 2.57 * 50000 / 300 / 100;
% hold on;
% surf(xx * pixToMeters, yy * pixToMeters, zz * 10, map(1 : stx, 1 : sty, :), 'FaceColor','texturemap', 'EdgeColor', 'none');
% axis equal tight;