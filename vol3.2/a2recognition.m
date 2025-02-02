rng(0);
nImg = 10;
nC = 10;

% Обучающие данные для второго каскада
% load netrec;
% load reccolormap;
% load("netrec9.mat", "rnn9CD");
% feature = [];
% target = [];
% count = 0;
% for i = 0 : nImg - 1
%     disp(i);
%     data = load("train\data_" + i + ".mat").data;
%     img = imread("train\seg_" + i + ".png");
%     img0 = imread("train\img_" + i + ".jpg");
%     img = single(img) / 255;
%     sizeX = size(img, 1);
%     sizeY = size(img, 2);
%     loc = imread("train\ga_" + i + ".png");
%     mskind = zeros(sizeX, sizeY);
%     for ic = 0 : nC - 1
%         ind = data(:, 6) == ic;
%         mskind(data(ind, 2) + sizeX * (data(ind, 7) - 1)) = ic + 1;
%         ind = data(:, 4) == ic;
%         mskind(data(ind, 2) + sizeX * (data(ind, 5) - 1)) = ic + 1;
%     end
% 
%     [xx, yy] = find(loc);
%     points = [xx'; yy'];
%     input = getnbh(img, points, [13, 11], 0);
%     output = sim(rnn9CD.Network, input);
%     isdig = sim(rnn0.Network, input);
%     output = output .* isdig;
%     output = output .* (output > 0.1);
%     [pdig, dig] = max(output);
%     outputmap = zeros(sizeX, sizeY);
%     outputmap(xx + sizeX * (yy - 1)) = dig .* (pdig > 0);
%     measuremap = zeros(sizeX, sizeY);
%     measuremap(xx + sizeX * (yy - 1)) = pdig;
%     tempmap = zeros(sizeX, sizeY);
%     for ic = 1 : nC
%         outlog = outputmap == ic;
%         outlog = bwareaopen(outlog, 2, 4);
%         tempmap = tempmap + outlog .* ic;
%     end
%     outputmap = tempmap;
%     clear xx yy input output pdig dig tempmap outlog;
% 
%     outputmap = outputmap .* bwareaopen(outputmap > 0, 5, 8);
%     outputmap([1 : 5, sizeX - 4 : sizeX], :) = 0;
%     outputmap(:, [1 : 5, sizeY - 4 : sizeY]) = 0;
%     [outLabel, nL] = bwlabel(outputmap > 0, 8);
%     prop = regionprops(outLabel, 'BoundingBox', 'Area');
%     for il = 1 : nL
%         if prop(il).Area > 28
%             box = prop(il).BoundingBox;
%             outputmap(floor(box(2)) : floor(box(2)) + box(4), floor(box(1)) + round(box(3) / 2)) = 0;
%         end
%     end
%     clear outLabel nL prop box;
% 
%     [outLabel, nL] = bwlabel(outputmap > 0, 8);
%     prop = regionprops(outLabel, 'Centroid', 'PixelIdxList', 'Area');
%     cnd = [prop.Centroid];
%     xx = floor(cnd(2 : 2 : end));
%     yy = floor(cnd(1 : 2 : end));
%     feature = [feature, zeros(nC, nL)];
%     target = [target, zeros(1, nL)];
%     for il = 1 : nL
%         [dr, dc] = find(mskind(xx(il) - 4 : xx(il) + 4, yy(il) - 4 : yy(il) + 4) > 0);
%         if numel(dr) == 1
%             target(count + il) = mskind(xx(il) + dr - 5, yy(il) + dc - 5);
%         end
%         ind = prop(il).PixelIdxList;
%         % st = stats(i).PixelList;
%         temp = accumarray(outputmap(ind),  measuremap(ind), [nC, 1]);
%         % ./ (1 + kr * ((xx(i) - st(:, 2)) .^ 2 + (yy(i) - st(:, 1)) .^ 2));
%         feature(:, count + il) = temp;
%         feature(:, count + il) = feature(:, count + il) / sum(feature(:, count + il));
%     end
%     count = count + nL;
%     clear prop cnd xx yy dr dc ind temp;
% end
% targettrain = target(target ~= 0);
% targettrain = full(ind2vec(targettrain));
% featuretrain = feature(:, target ~= 0);
% 
% ind = randperm(size(featuretrain, 2), 500); % knn
% knn1 = fitcknn(featuretrain(:, ind)', vec2ind(targettrain(:, ind)), 'NumNeighbors', 1);
% knn3 = fitcknn(featuretrain(:, ind)', vec2ind(targettrain(:, ind)), 'NumNeighbors', 3);
% tree10 = fitctree(featuretrain', vec2ind(targettrain), 'MaxNumSplits', 10);
% tree20 = fitctree(featuretrain', vec2ind(targettrain), 'MaxNumSplits', 20);
% tree100 = fitctree(featuretrain', vec2ind(targettrain), 'MaxNumSplits', 100);
% tree1000 = fitctree(featuretrain', vec2ind(targettrain), 'MaxNumSplits', 1000);
% ind = randperm(size(featuretrain, 2), 1000);
% for ic = 1 : nC
%     svm1{ic} = fitcsvm(featuretrain(:, ind)', targettrain(ic, ind)');
% end

% Тестирование второго каскада
load netrec;
load recsecond;
load reccolormap;
load("netrec9.mat", "rnn9CD");
tp = zeros(nC, 1);
predpos = zeros(nC, 1);
actpos = zeros(nC, 1);
tpid = zeros(nC, 1);
predposid = zeros(nC, 1);
tt = 0;
for i = nImg : 2 * nImg - 1
    disp(i);
    data = load("train\data_" + i + ".mat").data;
    img = imread("train\seg_" + i + ".png");
    img0 = imread("train\img_" + i + ".jpg");
    img = single(img) / 255;
    sizeX = size(img, 1);
    sizeY = size(img, 2);
    loc = imread("train\ga_" + i + ".png");
    mskind = zeros(sizeX, sizeY);
    for ic = 0 : nC - 1
        ind = data(:, 6) == ic;
        mskind(data(ind, 2) + sizeX * (data(ind, 7) - 1)) = ic + 1;
        ind = data(:, 4) == ic;
        mskind(data(ind, 2) + sizeX * (data(ind, 5) - 1)) = ic + 1;
    end

    [xx, yy] = find(loc);
    points = [xx'; yy'];
    input = getnbh(img, points, [13, 11], 0);
    output = sim(rnn9CD.Network, input);
    isdig = sim(rnn0.Network, input);
    output = output .* isdig;
    output = output .* (output > 0.1);
    [pdig, dig] = max(output);
    outputmap = zeros(sizeX, sizeY);
    outputmap(xx + sizeX * (yy - 1)) = dig .* (pdig > 0);
    measuremap = zeros(sizeX, sizeY);
    measuremap(xx + sizeX * (yy - 1)) = pdig;

    tic
    tempmap = zeros(sizeX, sizeY);
    for ic = 1 : nC
        outlog = outputmap == ic;
        outlog = bwareaopen(outlog, 2, 4);
        tempmap = tempmap + outlog .* ic;
    end
    outputmap = tempmap;
    clear xx yy input output pdig dig tempmap outlog;

    outputmap = outputmap .* bwareaopen(outputmap > 0, 5, 8);
    outputmap([1 : 5, sizeX - 4 : sizeX], :) = 0;
    outputmap(:, [1 : 5, sizeY - 4 : sizeY]) = 0;
    [outLabel, nL] = bwlabel(outputmap > 0, 8);
    prop = regionprops(outLabel, 'BoundingBox', 'Area');
    for il = 1 : nL
        if prop(il).Area > 28
            box = prop(il).BoundingBox;
            outputmap(floor(box(2)) : floor(box(2)) + box(4), floor(box(1)) + round(box(3) / 2)) = 0;
        end
    end
    clear outLabel nL prop box;

    [outLabel, nL] = bwlabel(outputmap > 0, 8);
    prop = regionprops(outLabel, 'Centroid', 'PixelIdxList', 'Area');
    cnd = [prop.Centroid];
    xx = floor(cnd(2 : 2 : end));
    yy = floor(cnd(1 : 2 : end));
    feature = zeros(nC, nL);
    target = zeros(1, nL);
    for il = 1 : nL
        [dr, dc] = find(mskind(xx(il) - 4 : xx(il) + 4, yy(il) - 4 : yy(il) + 4) > 0);
        if numel(dr) == 1
            target(il) = mskind(xx(il) + dr - 5, yy(il) + dc - 5);
        end
        ind = prop(il).PixelIdxList;
        % st = stats(i).PixelList;
        temp = accumarray(outputmap(ind),  measuremap(ind), [nC, 1]);
        % ./ (1 + kr * ((xx(i) - st(:, 2)) .^ 2 + (yy(i) - st(:, 1)) .^ 2));
        feature(:, il) = temp;
        feature(:, il) = feature(:, il) / sum(feature(:, il));
    end
        output = sim(snn100.Network, feature);
    %     output = predict(knn3, feature');
    %     output = output';
        [~, output] = max(output);
    %     output = zeros(nC, nL);
    %     for ic = 1 : nC
    %         output(ic, :) = predict(svm1{ic}, feature');
    %     end
    %     [~, output] = max(output);
%     [~, output] = max(feature);
    tt = tt + toc;

    tp(i - nImg + 1) = sum(output == target);
    predpos(i - nImg + 1) = numel(target);
    actpos(i - nImg + 1) = sum(mskind > 0, "all");
    tpid(i - nImg + 1) = sum((output == target) & (output ~= 0));
    predposid(i - nImg + 1) = sum(target ~= 0);
    clear prop cnd xx yy dr dc ind temp;
end
disp(["Recall ", 100 * sum(tp) / sum(actpos)]);
disp(["Common Precision ", 100 * sum(tp) / sum(predpos)]);
disp(["Identity Precision ",100 * sum(tpid) / sum(predposid)]);
disp(["Time ", tt / (nImg * sizeX * sizeY / 10 ^ 6)]);

% [~, output] = max(feature);
% disp(["Common Precision ", 100 * sum(output == target) / numel(target)]);
% disp(["Identity Precision ",100 * sum((output == target) & (output ~= 0)) / sum(target ~= 0)]);

% imtool(uint8(ind2rgb(outputmap + 1, colormap) * 255))
% implay(cat(4, uint8(ind2rgb(outputmap + 1, colormap) * 255), repmat(uint8(img * 255), [1, 1, 3])))