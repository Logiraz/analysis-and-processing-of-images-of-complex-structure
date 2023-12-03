function cluster = groupDigitsBrown(digit, sizes, edges, ro, scaleStep)
sizeX = sizes(1);
sizeY = sizes(2);
edgeMin = edges(1);
edgeMax = edges(2);

cluster = clusterDigitBrown(digit{1}, [20, 20]);
cluster = cluster([cluster.value] >= 10);
cluster = clusterFilterBrown(cluster, digit{1}, ro, 0);
cluster = cluster([cluster.value] >= edgeMin & [cluster.value] <= edgeMax);
cluster(mod([cluster.value], scaleStep) ~= 0) = [];

cluster2 = clusterDigitBrown(digit{2}, [20, 20], 1);
cluster2 = cluster2([cluster2.value] >= 10);
cluster2 = clusterFilterBrown(cluster2, digit{2}, ro, 1);
cluster2 = cluster2([cluster2.value] >= edgeMin & [cluster2.value] <= edgeMax);
cluster2(mod([cluster2.value], scaleStep) ~= 0) = [];
idMap2 = zeros(sizeX, sizeY);
idMap2([cluster2.xx] + sizeX * ([cluster2.yy] - 1)) = 1 : numel(cluster2);

% Выбор только одной отметки из двух, лежащих рядом
w = 15;
ind = [];
for iC = 1 : numel(cluster)
    [dX, dY] = find(idMap2(max(1, cluster(iC).xx - w) : min(sizeX, cluster(iC).xx + w), ...
        max(1, cluster(iC).yy - w) : min(sizeY, cluster(iC).yy + w)) > 0);
    jC = 0;
    if numel(dX) >= 1
        [~, i] = min((dX - (w + 1)) .^ 2 + (dY - (w + 1)) .^ 2);
        jC = idMap2(cluster(iC).xx + dX(i) - (w + 1), cluster(iC).yy + dY(i) - (w + 1));
    end
    if jC > 0
        ind(end + 1) = jC;
    end
end
cluster2(ind) = [];
cluster = table2struct([struct2table(cluster); struct2table(cluster2)]);
end