rng(0);
nImg = 10;
nC = 10;

% Сбор данных для ИНС "цифра - не цифра"
% nhood = [1 0 0 1 0 0 1; 0 0 0 0 0 0 0; 0 0 0 0 0 0 0; ...
% 1 0 0 0 0 0 1;0 0 0 0 0 0 0; 0 0 0 0 0 0 0; 1 0 0 1 0 0 1];
% % x - - x - - x
% % - - - - - - -
% % - - I I I - -
% % x - I I I - x
% % - - I I I - -
% % - - - - - - -
% % x - - x - - x
% % '-' = -1, 'x' = 0, 'I' = 1
% pic = [];
% val = [];
% for i = 0 : 1 % nImg - 1
%     data = load("train\data_" + i + ".mat").data;
%     img = imread("train\seg_" + i + ".png");
%     img = single(img) / 255;
%     sizeX = size(img, 1);
%     sizeY = size(img, 2);
%     [~, mskc] = getgamask([sizeX, sizeY], data);
% 
%     detnumb = imdilate(mskc, strel('square', 3)) * 2 - 1;
%     detnumb = detnumb + imdilate(mskc, strel('arbitrary', nhood));
%     [xx, yy] = find(detnumb >= 0);
%     points = [xx'; yy'];
%     pici = getnbh(img, points, [13, 11], 0);
%     pic = [pic, pici];
%     val = [val, detnumb(xx + sizeX * (yy - 1))'];
% end

% Сбор данных для ИНС по классам цифр
% pic = [];
% val = [];
% for i = 0 : nImg - 1
%     data = load("train\data_" + i + ".mat").data;
%     img = imread("train\seg_" + i + ".png");
%     img = single(img) / 255;
%     sizeX = size(img, 1);
%     sizeY = size(img, 2);
% 
%     temppoints = [data(:, 2)'; data(:, 7)'];
% %     points = [temppoints + [-1; -1], temppoints + [-1; 0], temppoints + [-1; +1],...
% %               temppoints + [0; -1], temppoints + [0; 0], temppoints + [0; +1],...
% %               temppoints + [+1; -1], temppoints + [+1; 0], temppoints + [+1; +1]];
% %     points = [temppoints + [-1; 0], temppoints + [0; -1], temppoints, ...
% %               temppoints + [0; +1], temppoints + [+1; 0]];
%     points = [temppoints];
%     pici = getnbh(img, points, [13, 11], 0);
%     pic = [pic, pici];
% %     val = [val, data(:, 6)', data(:, 6)', data(:, 6)', data(:, 6)', data(:, 6)', ...
% %                 data(:, 6)', data(:, 6)', data(:, 6)', data(:, 6)'];
% %     val = [val, data(:, 6)', data(:, 6)', data(:, 6)', data(:, 6)', data(:, 6)'];
%     val = [val, data(:, 6)'];
% 
%     ind = data(:, 5) ~= -1;
%     temppoints = [data(ind, 2)'; data(ind, 5)'];
% %     points = [temppoints + [-1; -1], temppoints + [-1; 0], temppoints + [-1; +1],...
% %               temppoints + [0; -1], temppoints + [0; 0], temppoints + [0; +1],...
% %               temppoints + [+1; -1], temppoints + [+1; 0], temppoints + [+1; +1]];
% %     points = [temppoints + [-1; 0], temppoints + [0; -1], temppoints, ...
% %               temppoints + [0; +1], temppoints + [+1; 0]];
%     points = [temppoints];
%     pici = getnbh(img, points, [13, 11], 0);
%     pic = [pic, pici];
% %     val = [val, data(ind, 4)', data(ind, 4)', data(ind, 4)', data(ind, 4)', data(ind, 4)',...
% %                 data(ind, 4)', data(ind, 4)', data(ind, 4)', data(ind, 4)'];
% %     val = [val, data(ind, 4)', data(ind, 4)', data(ind, 4)', data(ind, 4)', data(ind, 4)'];
%     val = [val, data(ind, 4)'];
% end
% val = full(ind2vec(val + 1));
% здесь происходит обучение

% knn = fitcknn(pic', vec2ind(val), 'NumNeighbors', 1); %3
% % knnp = predict(knn, inputn2');
% tree = fitctree(pic', vec2ind(val), 'MaxNumSplits', 100); %1000
% % knnp = predict(tree, inputn2');
% ind = randperm(size(val, 2), floor(size(val, 2) / 10));
% for i = 1 : nC
%     svm1{i} = fitcsvm(pic(:, ind)', val(i, ind)');
% end

load netrec;
load reccolormap;
load("netrec9.mat", "rnn9CD");
% mdl = {rnn1L.Network, rnn1C.Network, rnn1CC.Network, rnn1CD.Network, ...
%        rnn5L.Network, rnn5C.Network, rnn5CC.Network, rnn5CD.Network, ...
%        rnn9L.Network, rnn9C.Network, rnn9CC.Network, rnn9CD.Network};
% mdl = {knn11, knn51, knn91, knn13, knn53, knn93};
% mdl = {svm5, svm9};
% for ex = 1 : numel(mdl)
%     disp(ex);
%     ind = randperm(size(val, 2), 500); % knn
%     knn = fitcknn(pic(:, ind)', vec2ind(val(:, ind)), 'NumNeighbors', mdl{ex});
%     tree = fitctree(pic', vec2ind(val), 'MaxNumSplits', mdl{ex});
tp = zeros(nImg, nC);
actpos = zeros(nImg, nC);
predpos = zeros(nImg, nC);
%     tt = 0;
for i = 0 : 0%2 * nImg - 1
    disp(i);
    data = load("train\data_" + i + ".mat").data;
    img = imread("train\seg_" + i + ".png");
    img = single(img) / 255;
    loc = imread("train\ga_" + i + ".png");
    sizeX = size(img, 1);
    sizeY = size(img, 2);
    mskind = zeros(sizeX, sizeY);
    for ic = 0 : nC - 1
        ind = data(:, 6) == ic;
        mskind(data(ind, 2) + sizeX * (data(ind, 7) - 1)) = ic + 1;
        ind = data(:, 4) == ic;
        mskind(data(ind, 2) + sizeX * (data(ind, 5) - 1)) = ic + 1;
    end
    mskind = imdilate(mskind, strel("square", 5));

    %         tic
    [xx, yy] = find(loc);
    points = [xx'; yy'];
    nWin = numel(xx);
    input = getnbh(img, points, [13, 11], 0);
    output = sim(rnn9CD.Network, input);
    % %         output = predict(tree, input');
    isdig = sim(rnn0.Network, input);
    output = output .* isdig;
    output = output .* (output > 0.1);
    [pdig, dig] = max(output);
    %    output = zeros(nC, nWin);
    %         for ic = 1 : nC
    %             output(ic, :) = predict(mdl{ex}{ic}, input');
    %         end
    outputmap = zeros(sizeX, sizeY);
    outputmap(xx + sizeX * (yy - 1)) = dig .* (pdig > 0);
    % %         outputmap(xx + sizeX * (yy - 1)) = output;
    %         tt = tt + toc;
%     outputmapnew = zeros(sizeX, sizeY);
%     for ic = 1 : nC
%         outlog = outputmap == ic;
%         outlog = bwareaopen(outlog, 2, 4);
%         outputmapnew = outputmapnew + outlog .* ic;
%         outLabel = bwlabel(outlog, 4) > 0;
%         prop = regionprops(outLabel, 'Centroid');
%         cnd = [prop.Centroid];
%         cy = round(cnd(1 : 2 : end));
%         cx = round(cnd(2 : 2 : end));
%         outlog = zeros(sizeX, sizeY);
%         outlog(cx + sizeX * (cy - 1)) = 1;
%         msklog = mskind == ic;
%         [mskLabel, nL] = bwlabel(msklog, 4);
%         prop = regionprops(mskLabel, 'BoundingBox');
%         box = floor([prop.BoundingBox]);
%         for il = 1 : nL
%             if sum(outlog(box(il * 4 - 2) : box(il * 4 - 2) + box(il * 4 - 0), ...
%                     box(il * 4 - 3) : box(il * 4 - 3) + box(il * 4 - 1)), "all") > 0
%                 tp(i - nImg + 1, ic) = tp(i - nImg + 1, ic) + 1;
%             end
%         end
%         tp(i - nImg + 1, ic) = sum(msklog & outlog, "all");
%         actpos(i - nImg + 1, ic) = sum(msklog, "all") / 25;
%         predpos(i - nImg + 1, ic) = sum(outlog, "all");
%     end
end
%     disp(["Recall ", sum(tp, "all") ./ sum(actpos, "all")]);
%     disp(sum(tp) ./ sum(actpos));
%     disp(["Precision ", sum(tp, "all") ./ sum(predpos, "all")]);
%     disp(sum(tp) ./ sum(predpos));
%     disp(["Time ", tt / (nImg * sizeX * sizeY / 10 ^ 6)]);
% end

imtool(uint8(ind2rgb(outputmap + 1, colormap) * 255))
% implay(cat(4, uint8(ind2rgb(outputmap + 1, colormap) * 255), repmat(uint8(img * 255), [1, 1, 3])))