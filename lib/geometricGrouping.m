function [lineMap, endPoint, dist] = geometricGrouping(lineMap, endPoint, dist, iteration)
label = bwlabel(lineMap);
xx = [endPoint.xx];
yy = [endPoint.yy];
iL = [endPoint.iL];
nEP = numel(endPoint);
ind = find([endPoint.onEdge] == 0);

% Расчёт угла касательной к концевым точкам
alpha = zeros(nEP, 1);
w = 5;
for iP = ind
    segEP = label(xx(iP) + (-w : w), yy(iP) + (-w : w)) == iL(iP);
    [segX, segY] = find(segEP > 0);
    dX = mean(segX, "all") - (w + 1);
    dY = mean(segY, "all") - (w + 1);
    alpha(iP) = -atan2(dX, dY);
end

% Расчёт условий I-III
phi = abs(alpha - alpha');
condition_1 = dist < 5;
condition_2 = (dist < (10 + 5 * iteration)) & (phi > pi() / 2) & (phi < 3 * pi() / 2);
[first, second] = find(condition_2);
condition_3 =  false(nEP);
for iP = 1 : numel(first)
    alphaFirstOut = -atan2(xx(first(iP)) - xx(second(iP)), yy(first(iP)) - yy(second(iP)));
    alphaSecondOut = -atan2(xx(second(iP)) - xx(first(iP)), yy(second(iP)) - yy(first(iP)));
    if abs(alphaFirstOut - alpha(first(iP))) > 1.5 * pi()
        if alphaFirstOut > alpha(first(iP))
            alpha(first(iP)) = alpha(first(iP)) + 2 * pi();
        else
            alphaFirstOut = alphaFirstOut + 2 * pi();
        end
    end
    if abs(alphaSecondOut - alpha(second(iP))) > 1.5 * pi()
        if alphaSecondOut > alpha(second(iP))
            alpha(second(iP)) = alpha(second(iP)) + 2 * pi();
        else
            alphaSecondOut = alphaSecondOut + 2 * pi();
        end
    end
    condition_3(first(iP), second(iP)) = (abs(alphaFirstOut - alpha(first(iP))) < pi() / 6) & (abs(alphaSecondOut - alpha(second(iP))) < pi() / 6);
end

% Нахождение пар для единственного соединения для данной концевой точки
complexCondition = condition_2 & (condition_1 | condition_3);
sumCondition = sum(complexCondition, 2);
nPair = 0;
pair = zeros(nEP, 2);
flag = zeros(nEP);
for iP = ind
    if sumCondition(iP) == 1
        jP = find(complexCondition(iP, :));
        if sumCondition(jP) && ~flag(jP, iP)
            nPair = nPair + 1;
            flag(iP, jP) = 1;
            pair(nPair, :) = [iP, jP];
        end
    end
end
pair = pair(1 : nPair, :);

% Рисование линий-соединителей
% RGB = zeros([size(lineMap, 1), size(lineMap, 2), 3], "single");
% RGB(:, :, 1) = lineMap;
lineMap = drawLines(lineMap, endPoint, pair);
% RGB(:, :, 2) = lineMap;
% imtool(RGB);

[endPoint, dist] = getEndPoints(lineMap);
end