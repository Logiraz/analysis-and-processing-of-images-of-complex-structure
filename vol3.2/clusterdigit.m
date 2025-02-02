function clstr = clusterdigit(xx, yy, value)
nD = numel(value);
nCr = 0;
maxy = max(yy);
maxdx = 5;
maxdy = 15;
nB = ceil(maxy / maxdy);
bucket = cell(nB, 1);
clstr = struct('ind', 1, 'value', value(1), 'xx', xx(1), 'yy', yy(1));

for id = 1 : nD
    flag = 0;
    k = ceil(yy(id) / maxy * nB);
    for ic = [bucket{max(k - 1, 1) : min(k + 1, nB)}]
        if (abs(xx(id) - clstr(ic).xx) <= maxdx) && (abs(yy(id) - clstr(ic).yy) <= maxdy) && (flag == 0)
            clstr(ic).ind = [clstr(ic).ind, id];
            clstr(ic).xx = round(mean(xx(clstr(ic).ind)));
            clstr(ic).yy = round(mean(yy(clstr(ic).ind)));
            [~, order] = sort(yy(clstr(ic).ind));
            clstr(ic).value = str2double(sprintf('%d', value([clstr(ic).ind(order)])));
            flag = 1;
            break;
        end
    end
    if flag == 0
        nCr = nCr + 1;
        clstr(nCr).ind = id;
        clstr(nCr).value = value(id);
        clstr(nCr).xx = xx(id);
        clstr(nCr).yy = yy(id);
        k = ceil(yy(id) / maxy * nB);
        bucket{k} = [bucket{k}, nCr];
    end
end
end