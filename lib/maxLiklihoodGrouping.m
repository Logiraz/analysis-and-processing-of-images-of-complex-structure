function [lineMap, endPoint, dist] = maxLiklihoodGrouping(lineMap, cluster, endPoint, dist, params)
kGamma = params(1);
maxScore = params(2);
label = bwlabel(lineMap);
w = 10;
padLabel = padarray(label, [w, w], 0, "both");
xx = [endPoint.xx];
yy = [endPoint.yy];
iL = [endPoint.iL];

nPair = 0;
pair = zeros(sum([cluster.nEdge]), 2);
for iC = 1 : numel(cluster)
    if cluster(iC).nVertex <= 100
        % Расчёт угла касательной к сегменту
        alpha = zeros(cluster(iC).nVertex, 1);
        for iV = 1 : cluster(iC).nVertex
            segEP = padLabel(xx(cluster(iC).vertex(iV)) + (0 : 2*w), yy(cluster(iC).vertex(iV)) + (0 : 2*w)) == iL(cluster(iC).vertex(iV));
            [segX, segY] = find(segEP > 0);
            dX = mean(segX, "all") - (w + 1);
            dY = mean(segY, "all") - (w + 1);
            alpha(cluster(iC).vertex(iV)) = -atan2(dX, dY);
        end

        % Расчёт меры из условия V
        gamma =  zeros(cluster(iC).nVertex);
        for iE = 1 : cluster(iC).nEdge
            first = cluster(iC).edge(iE, 1);
            second = cluster(iC).edge(iE, 2);
            alphaFirstOut = -atan2(xx(first) - xx(second), yy(first) - yy(second));
            alphaSecondOut = -atan2(xx(second) - xx(first), yy(second) - yy(first));
            if abs(alphaFirstOut - alpha(first)) > 1.5 * pi()
                if alphaFirstOut > alpha(first)
                    alpha(first) = alpha(first) + 2 * pi();
                else
                    alphaFirstOut = alphaFirstOut + 2 * pi();
                end
            end
            if abs(alphaSecondOut - alpha(second)) > 1.5 * pi()
                if alphaSecondOut > alpha(second)
                    alpha(second) = alpha(second) + 2 * pi();
                else
                    alphaSecondOut = alphaSecondOut + 2 * pi();
                end
            end
            gamma(first, second) = abs(alphaFirstOut - alpha(first)) + abs(alphaSecondOut - alpha(second));
        end

        flag = 1;
        while flag
            gammaEdge = zeros(cluster(iC).nEdge, 1);
            distEdge = zeros(cluster(iC).nEdge, 1);
            for iE = 1 : cluster(iC).nEdge
                gammaEdge(iE) = gamma(cluster(iC).edge(iE, 1), cluster(iC).edge(iE, 2));
                distEdge(iE) = dist(cluster(iC).edge(iE, 1), cluster(iC).edge(iE, 2));
            end
            [score, pos] = min(distEdge - kGamma * pi() ./ (gammaEdge + 1e-3));
            if score < maxScore
                nPair = nPair + 1;
                pair(nPair, :) = cluster(iC).edge(pos, :);
                [adjacentWithFirst, ~] = find(cluster(iC).edge == pair(nPair, 1));
                [adjacentWithSecond, ~] = find(cluster(iC).edge == pair(nPair, 2));
                indAE = union(adjacentWithFirst, adjacentWithSecond);
                cluster(iC).edge(indAE, :) = [];
                cluster(iC).nEdge = cluster(iC).nEdge - numel(indAE);
            else
                flag = 0;
            end
        end
%         for iE = 1 : cluster(iC).nEdge
%             first = cluster(iC).edge(iE, 1);
%             second = cluster(iC).edge(iE, 2);
%             if first > 0
%                 [adjacentWithFirst, ~] = find(cluster(iC).edge == first);
%                 [adjacentWithSecond, ~] = find(cluster(iC).edge == second);
%                 indAE = union(adjacentWithFirst, adjacentWithSecond);
%                 adjacentEdge = cluster(iC).edge(indAE, :);
%                 gammaEdge = zeros(size(adjacentEdge, 1), 1);
%                 distEdge = zeros(size(adjacentEdge, 1), 1);
%                 for iAE = 1 : size(adjacentEdge, 1)
%                     gammaEdge(iAE) = gamma(adjacentEdge(iAE, 1), adjacentEdge(iAE, 2));
%                     distEdge(iAE) = dist(adjacentEdge(iAE, 1), adjacentEdge(iAE, 2));
%                 end
%                 [~, pos] = min(0 * distEdge - 4 * pi() ./ (gammaEdge + 1e-3));
%                 if (adjacentEdge(pos, 1) == first) && (adjacentEdge(pos, 2) == second)
%                     nPair = nPair + 1;
%                     pair(nPair, 1 : 2) = [first second];
%                     cluster(iC).edge(indAE, :) = zeros(size(indAE, 1), 2);
%                 end
%             end
%         end
    end
end
pair(pair(:, 1) == 0, :) = [];
lineMap = drawLines(lineMap, endPoint, pair);
[endPoint, dist] = getEndPoints(lineMap, 1);
end