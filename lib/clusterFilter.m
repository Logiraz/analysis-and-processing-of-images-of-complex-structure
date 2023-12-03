function cluster = clusterFilter(cluster, xx, yy, value, ro)
for iC = 1 : numel(cluster)
    ind = cluster(iC).ind;

    % Попытка найти 4-значное число в кластере
    choose =  nchoosek(ind, 4);
    flag = ones(size(choose, 1), 1);
    for iH = 1 : size(choose, 1)

        % Проверка на небольшое отклонение по вертикали
        xmean = mean(xx(choose(iH, :)));
        for j = 1 : 4
            if abs(xx(choose(iH, j)) - xmean) > 3
                flag(iH) = 0;
            end
        end

        % Соседние цифры должны быть на расстоянии ro друг от друга
        for j = 1 : 2
            if abs(abs(yy(choose(iH, j + 1)) - yy(choose(iH, j))) - ...
                    ro(value(choose(iH, j)) + 1, value(choose(iH, j + 1)) + 1)) > 4
                flag(iH) = 0;
            end
        end

        % ro + 6, если это последняя цифра, так как там стоит десятичная запятая
        j = 3;
        if abs(abs(yy(choose(iH, j + 1)) - yy(choose(iH, j))) - ...
                ro(value(choose(iH, j)) + 1, value(choose(iH, j + 1)) + 1) - 6) > 4
            flag(iH) = 0;
        end
    end

    if sum(flag) > 0
        % Если есть всего два варианта, то оставить тот, у которого
        % раастояние между двумя последними цифрами больше
        if sum(flag) == 2
            vars = find(flag);
            if yy(choose(vars(1), 4)) - yy(choose(vars(1), 3)) > yy(choose(vars(2), 4)) - yy(choose(vars(2), 3))
                flag(vars(2)) = 0;
            else
                flag(vars(1)) = 0;
            end
        end
        % Найти цифры, которые чаще всего встречаются и пересоздать кластер
        % относительно них
        digits = choose(find(flag), :);
        [counts, group] = groupcounts(digits(:));
        [~, tmp] = maxk(counts, 4);
        cluster(iC).ind = group(tmp);
        cluster(iC).xx = round(mean(xx(cluster(iC).ind)));
        cluster(iC).yy = round(mean(yy(cluster(iC).ind)));
        [~, order] = sort(yy(cluster(iC).ind));
        cluster(iC).value = str2double(sprintf('%d', value([cluster(iC).ind(order)])));
    else

        % Попытка найти 3-значное число в кластере
        choose =  nchoosek(ind, 3);
        flag = ones(size(choose, 1), 1);
        for iH = 1 : size(choose, 1)
            xmean = mean(xx(choose(iH, :)));
            for j = 1 : 3
                if abs(xx(choose(iH, j)) - xmean) > 3
                    flag(iH) = 0;
                end
            end
            j = 1;
            if abs(abs(yy(choose(iH, j + 1)) - yy(choose(iH, j))) - ...
                    ro(value(choose(iH, j)) + 1, value(choose(iH, j + 1)) + 1)) > 4
                flag(iH) = 0;
            end
            j = 2;
            if abs(abs(yy(choose(iH, j + 1)) - yy(choose(iH, j))) - ...
                    ro(value(choose(iH, j)) + 1, value(choose(iH, j + 1)) + 1) - 6) > 4
                flag(iH) = 0;
            end
        end

        if sum(flag) > 0
            digits = choose(find(flag), :);
            [counts, group] = groupcounts(digits(:));
            [~, tmp] = maxk(counts, 3);
            cluster(iC).ind = group(tmp);
            cluster(iC).xx = round(mean(xx(cluster(iC).ind)));
            cluster(iC).yy = round(mean(yy(cluster(iC).ind)));
            [~, order] = sort(yy(cluster(iC).ind));
            cluster(iC).value = str2double(sprintf('%d', value([cluster(iC).ind(order)])));
        else
            % Если не были найдены ни 4-значные, ни 3-значные числа, то
            % удалить кластер
            cluster(iC).value = -1;
        end
    end
end
cluster = cluster([cluster.value] >= 1e2);
end