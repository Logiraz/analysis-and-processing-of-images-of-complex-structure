function cluster = clusterFilterBrown(cluster, digit, ro, iType)
nn = 3;
xx = digit.xx;
yy = digit.yy;
value = digit.value;

for iC = 1 : numel(cluster)
    ind = cluster(iC).ind;

    % Попытка найти 3-значное число в кластере
    choose =  nchoosek(ind, nn);
    flag = ones(size(choose, 1), 1);
    for iH = 1 : size(choose, 1)
        % Соседние цифры должны быть на расстоянии ro друг от друга
        for j = 1 : (nn - 1)
            rr = ((xx(choose(iH, j + 1)) - xx(choose(iH, j))) ^ 2 + ...
                  (yy(choose(iH, j + 1)) - yy(choose(iH, j))) ^ 2) ^ 0.5;
            if abs(rr - ro(value(choose(iH, j)) + 1, value(choose(iH, j + 1)) + 1)) > 5
                flag(iH) = 0;
            end
        end
    end
    
    if sum(flag) > 0
        % Найти цифры, которые чаще всего встречаются и пересоздать кластер
        % относительно них
        digits = choose(find(flag), :);
        [counts, group] = groupcounts(digits(:));
        [~, tmp] = maxk(counts, 3);
        cluster(iC).ind = group(tmp);
        cluster(iC).xx = round(mean(xx(cluster(iC).ind)));
        cluster(iC).yy = round(mean(yy(cluster(iC).ind)));
        if iType
            [~, order] = sort(yy(cluster(iC).ind) * sin(cluster(iC).phi) + ...
                              xx(cluster(iC).ind) * cos(cluster(iC).phi), 'descend');
        else
            [~, order] = sort(yy(cluster(iC).ind) * sin(cluster(iC).phi) + ...
                              xx(cluster(iC).ind) * cos(cluster(iC).phi));
        end
        cluster(iC).value = str2double(sprintf('%d', value([cluster(iC).ind(order)])));
    else
        % Если не получилось, то убрать кластер
        cluster(iC).value = -1;
    end
end
cluster = cluster([cluster.value] >= 10);
end