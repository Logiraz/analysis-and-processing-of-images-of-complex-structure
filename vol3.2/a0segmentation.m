% Получение данных для интеллектуальной модели для сегментации
% a = 1;
% nTest = 1000;
% nImg = 10;
% nbh = zeros(3 * a * a, 2 * nTest * nImg);
% val = zeros(1, 2 * nTest * nImg);
% 
% for i = 0 : nImg - 1
%     rng(i);
%     struct = load("train\data_" + string(i) + ".mat");
%     mskblack = struct.mskblack;
%     clear struct;
%     map = imread("train\img_" + string(i) + ".jpg");
% 
%     points = zeros(2, 2 * nTest);
%     [x, y] = find(mskblack == 1);
%     indx = randperm(numel(x), nTest);
%     points(:, 1 : nTest) = [x(indx)'; y(indx)'];
%     [x, y] = find(mskblack == 0);
%     indx = randperm(numel(x), nTest);
%     points(:, nTest + 1 : 2 * nTest) = [x(indx)'; y(indx)'];
%     clear x y;
% 
%     nbh(:, i * 2 * nTest + 1 : (i + 1) * 2 * nTest) = getnbh(map, points, a, 0);
%     val(i * 2 * nTest + 1 : i * 2 * nTest + nTest) = 1;
% end
% nbh = nbh / 255;
% Обучение модели нужно выполнить здесь и экспортировать модель в workspace

nImg = 10;
beta2 = 2;
a = 3;
load netseg;
% mdl = {0, 1, nn31.Network, nn33.Network, nn36.Network, ...
%      nn277.Network, nn2713.Network, nn2727.Network, nn2754.Network};
% a = [0, 0, 1, 1, 1, 3, 3, 3, 3];

% load models3;
% mdl = {ld.ClassificationDiscriminant, lr.GeneralizedLinearModel, nb.ClassificationNaiveBayes, ...
%     svm.ClassificationSVM, tree1.ClassificationTree, tree2.ClassificationTree, nn1010.ClassificationNeuralNetwork};
% a = ones(numel(mdl), 1) * 3;
for ex = 1 : 1
    rng(0);
%     disp("Size " + a(ex) + " model " + ex);
%     Fb = zeros(nImg, 1);
%     tic
    for seed = 0 : 2 * nImg - 1
        disp(seed);
        struct = load("train\data_" + string(seed) + ".mat");
        data = struct.data;
        mskblack = struct.mskblack;
        clear struct;
        map = imread("train\img_" + string(seed) + ".jpg");
        sizeX = size(map, 1);
        sizeY = size(map, 2);

        %         if a(ex) == 0
        %             if mdl{ex} == 0
        %                 output = max(map, [], 3) < 160;
        %             elseif mdl{ex} == 1
        %                 output = mean(map, 3) < 150;
        %             end
        %         else
        input = zeros(3 * a(ex) * a(ex), sizeX * sizeY, 'uint8');
        mapPadded = padarray(map, [(a(ex) - 1) / 2, (a(ex) - 1) / 2, 0], 255);
        for i = 1 : a(ex)
            for j = 1 : a(ex)
                mapShifted = mapPadded(i : i + sizeX - 1, j : j + sizeY - 1, :);
                mapShifted = permute(mapShifted, [3 2 1]);
                mapShifted = reshape(mapShifted, [3 sizeX * sizeY]);
                input((3 * (a(ex) * i + j - a(ex)) - 2) : (3 * (a(ex) * i + j - a(ex))), :) = mapShifted;
            end
        end
        clear mapShifted mapPadded i j;

        batch = 1 : floor((sizeX * sizeY) / (a(ex) * a(ex))) : (sizeX * sizeY + 1);
        batch(numel(batch)) = sizeX * sizeY + 1;
        for i = 1 : numel(batch) - 1
            inputBatch = single(input(1 : 3 * a(ex) * a(ex), batch(i) : batch(i + 1) - 1)) / 255;
            output(batch(i) : batch(i + 1) - 1) = sim(nn2713.Network, inputBatch);
            % output(batch(i) : batch(i + 1) - 1) = sim(nn10.ClassificationNeuralNetwork, inputBatch);
            % output(batch(i) : batch(i + 1) - 1) = predict(mdl{ex}, inputBatch');
        end
        output = reshape(output, [sizeY sizeX])';
%         output = 1 * (output > 0.5);
        % end
%         tp = sum(output & mskblack, "all");
%         fp = sum(output & ~mskblack, "all");
%         fn = sum(~output & mskblack, "all");
%         Fb(seed - nImg + 1) = (beta2 + 1) * tp / ((beta2 + 1) * tp + beta2 * fn + fp);
        imwrite(uint8(output * 255), "train\seg_" + string(seed) + ".png");
    end
%     toc / (1 * sizeX * sizeY / 10 ^ 6)
%     disp([mean(Fb) * 10, std(Fb)]);
end