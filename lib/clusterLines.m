function [cluster, iCluster] = clusterLines(pair)
nPair = size(pair, 1);
iCluster = zeros(max(pair(:)), 1);

cluster = struct("vertex", pair(1, :)', "nVertex", 2, "edge", pair(1, :), "nEdge", 1);
nCluster = 1;
iCluster(pair(1, :)) = 1;
for iP = 2 : nPair
    first = iCluster(pair(iP, 1));
    second = iCluster(pair(iP, 2));
    if (first == 0) && (second == 0)
        % Если обе точки не принадлежат ни одному кластеру, то создать новый
        nCluster = nCluster + 1;
        cluster(nCluster).nVertex = 2;
        cluster(nCluster).vertex = pair(iP, :)';
        cluster(nCluster).nEdge = 1;
        cluster(nCluster).edge = pair(iP, :);
        iCluster(pair(iP, :)) = nCluster;
    elseif (first ~= 0) && (second == 0)
        % Если одна принадлежит, а другая нет, то присоединить ребро в нужный кластер
        cluster(first).nVertex = cluster(first).nVertex + 1;
        cluster(first).vertex = [cluster(first).vertex; pair(iP, 2)];
        cluster(first).nEdge = cluster(first).nEdge + 1;
        cluster(first).edge = [cluster(first).edge; pair(iP, :)];
        iCluster(pair(iP, 2)) = first;
    elseif (first == 0) && (second ~= 0)
        % Аналогично
        cluster(second).nVertex = cluster(second).nVertex + 1;
        cluster(second).vertex = [cluster(second).vertex; pair(iP, 1)];
        cluster(second).nEdge = cluster(second).nEdge + 1;
        cluster(second).edge = [cluster(second).edge; pair(iP, :)];
        iCluster(pair(iP, 1)) = second;
    else
        if first ~= second
            % Если обе точке принадлежат кластерам, но разным, то объединить кластеры
            cluster(first).nVertex = cluster(first).nVertex + cluster(second).nVertex;
            cluster(first).vertex = [cluster(first).vertex; cluster(second).vertex];
            cluster(first).nEdge = cluster(first).nEdge + cluster(second).nEdge + 1;
            cluster(first).edge = [cluster(first).edge; cluster(second).edge; pair(iP, :)];
            iCluster(cluster(first).vertex) = first;
            cluster(second).nVertex = 0;
        else
            % Если к одному, то просто добавить новое ребро
            cluster(first).nEdge = cluster(first).nEdge + 1;
            cluster(first).edge = [cluster(first).edge; pair(iP, :)];
        end
    end
end
nEmptyCluster = zeros(numel(cluster), 1);
for iC = 1 : numel(cluster)
    if cluster(iC).nVertex == 0
        nEmptyCluster(iC : end) = nEmptyCluster(iC : end) + 1;
    end
end
ind = iCluster > 0;
iCluster(ind) = iCluster(ind) - nEmptyCluster(iCluster(ind));
cluster([cluster.nVertex] == 0) = [];
end