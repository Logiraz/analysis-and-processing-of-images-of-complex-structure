function cluster = semanticFilter(cluster)
sorted = sort([cluster.value]);
expDiff = exp(diff(log(sorted))) < 1.2;
edge = find(diff([0, expDiff, 0]) ~= 0);
[~, pos] = max(edge(2 : end) - edge(1 : end - 1));
cluster = cluster([cluster.value] >= sorted(edge(pos)) & [cluster.value] <= sorted(edge(pos + 1)));
end