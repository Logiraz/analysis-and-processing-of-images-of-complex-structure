function cluster = clusterDigitBrown(digit, maxDiff, iType)
arguments
    digit
    maxDiff {mustBeReal} = [6, 50];
    iType {mustBeReal} = 0;
end
xx = digit.xx;
yy = digit.yy;
value = digit.value;
phi = digit.phi;
nD = numel(value);
nC = 0;
maxY = max(yy);
maxdX = maxDiff(1);
maxdY = maxDiff(2);
nB = ceil(maxY / maxdY);
bucket = cell(nB, 1);
cluster = struct('ind', 1, 'value', value(1), 'xx', xx(1), 'yy', yy(1), 'phi', phi(1));

for iD = 1 : nD
    flag = 0;
    iBucket = ceil(yy(iD) / maxY * nB);
    for iC = [bucket{max(iBucket - 1, 1) : min(iBucket + 1, nB)}]
        if abs(xx(iD) - cluster(iC).xx) <= maxdX && ...
           abs(yy(iD) - cluster(iC).yy) <= maxdY && ...
           abs(sin(phi(iD) - cluster(iC).phi)) <= 0.7 && ...
           flag == 0
            cluster(iC).ind = [cluster(iC).ind, iD];
            cluster(iC).xx = round(mean(xx(cluster(iC).ind)));
            iBucketOld = ceil(cluster(iC).yy / maxY * nB);
            cluster(iC).yy = round(mean(yy(cluster(iC).ind)));
            iBucketNew = ceil(cluster(iC).yy / maxY * nB);
            if iBucketNew ~= iBucketOld
                bucket{iBucketNew} = [bucket{iBucketNew}, iC];
            end
            if iType
                [~, order] = sort(yy(cluster(iC).ind) * sin(cluster(iC).phi) + ...
                                  xx(cluster(iC).ind) * cos(cluster(iC).phi), 'descend');
            else
                [~, order] = sort(yy(cluster(iC).ind) * sin(cluster(iC).phi) + ...
                                  xx(cluster(iC).ind) * cos(cluster(iC).phi));
            end
            cluster(iC).ind = cluster(iC).ind(order);
            cluster(iC).phi = atan2(sum(sin(phi(cluster(iC).ind))), sum(cos(phi(cluster(iC).ind))));
            cluster(iC).value = str2double(sprintf('%d', value([cluster(iC).ind])));
            flag = 1;
            break;
        end
    end
    if flag == 0
        nC = nC + 1;
        cluster(nC).ind = iD;
        cluster(nC).value = value(iD);
        cluster(nC).xx = xx(iD);
        cluster(nC).yy = yy(iD);
        cluster(nC).phi = phi(iD);
        iBucket = ceil(yy(iD) / maxY * nB);
        bucket{iBucket} = [bucket{iBucket}, nC];
    end
end
end