rng(0);
nImg = 10;
nC = 10;

load recbest;
load reccolormap;
tp = 0;
tplabel = 0;
actpos = 0;
predpos = 0;
tt = 0;
for i = 0 : 2 * nImg - 1
    disp(i);
    data = load("train\data_" + i + ".mat").data;
    img = imread("train\seg_" + i + ".png");
    img0 = imread("train\img_" + i + ".jpg");
    img = single(img) / 255;
    sizeX = size(img, 1);
    sizeY = size(img, 2);
    loc = imread("train\ga_" + i + ".png");
    target = zeros(sizeX, sizeY) - 1;
    target(data(:, 2) + sizeX * (data(:, 3) - 1)) = data(:, 1);
    [xx, yy, value] = recimage(img, loc, rnn0, rnn9CD, snn100);
    value = value - 1;
    
    tic
    clstr = clusterdigit(xx, yy, value);

%     ind = find([clstr.value] < 10);
%     temp = imclose(img, strel("square", 5));
%     temp = imdilate(temp, strel("square", 3)) > 0.5;
%     loc1 = false(sizeX, sizeY);
%     for j = ind
%         if clstr(j).xx > 10 && clstr(j).xx < sizeX - 10
%             value1 = [];
%             value2 = [];
%             if clstr(j).yy > 20
%                 xlist = clstr(j).xx - 10 : clstr(j).xx + 10;
%                 ylist = clstr(j).yy - 20 : clstr(j).yy - 3;
%                 [xx1, yy1, value1] = recimage(img(xlist, ylist), temp(xlist, ylist), rnn0, rnn9CD, snn100);
%                 if numel(value1) > 1
%                     break;
%                 end
%             end
%             if clstr(j).yy < sizeY - 20
%                 xlist = clstr(j).xx - 10 : clstr(j).xx + 10;
%                 ylist = clstr(j).yy + 3 : clstr(j).yy + 20;
%                 [xx2, yy2, value2] = recimage(img(xlist, ylist), temp(xlist, ylist), rnn0, rnn9CD, snn100);
%                 if numel(value2) > 1
%                     break;
%                 end
%             end
%             if numel(value1) + numel(value2) == 1
%                 xx = [xx, xx1, xx2];
%                 yy = [yy, yy1, yy2];
%                 value = [value, value1 - 1, value2 - 1];
%             end
%         end
%     end
%     clstr = clusterdigit(xx, yy, value);

    ind = false(size(clstr, 2), 1);
    blue = rgb2hsv(img0);
    blue = blue(:, :, 1) > 0.5 & blue(:, :, 1) < 0.6 & blue(:, :, 2) > 0.1;
    blue = imclose(blue, strel("square", 5));
    blue = imopen(blue, strel("square", 5));
    for ic = 1 : size(clstr, 2)
        if clstr(ic).value < 10 && blue(clstr(ic).xx, clstr(ic).yy) == false
            ind(ic) = true;
        end
    end
    clstr(ind) = [];

    ind = [clstr.value] > 100;
    clstr(ind) = [];

    DT = delaunayTriangulation([clstr.xx]', [clstr.yy]');
    temp = DT.edges;
    ind = false(size(clstr, 2), 1);
    for ic = 1 : size(clstr, 2)
        [tempf, temps] = find(temp == ic);
        if min(abs(clstr(ic).value - [clstr(temp(tempf + size(temp, 1) * (2 - temps))).value])) > 15 && ...
            blue(clstr(ic).xx, clstr(ic).yy) == false   
            ind(ic) = true;
        end
    end
    clstr(ind) = [];
    tt = tt + toc;

    predicted = zeros(sizeX, sizeY) - 1;
    predicted([clstr.xx] + sizeX * ([clstr.yy] - 1)) = [clstr.value];

    target = imdilate(target, strel("square", 13));
    predicted = imdilate(predicted, strel("square", 13));
    [~, temp] = bwlabel((target == predicted) & (predicted >= 0), 4);
    tp = tp + temp;
    [~, temp] = bwlabel((target >= 0) & (predicted >= 0), 4);
    tplabel = tplabel + temp;
    actpos = actpos + size(data, 1);
    predpos = predpos + size(clstr, 2);

%     temp = (target == predicted) & (predicted >= 0) | (target < 0);
%     temp = max(img0 - uint8(temp .* double(img0)), [], 3);
%     ind = false(size(clstr, 2), 1);
%     for ic = 1 : numel(ind)
%         if temp(clstr(ic).xx, clstr(ic).yy) > 0
%             ind(ic) = true;
%         end
%     end

%     ind = false(size(clstr, 2), 1);
%     for ic = 1 : numel(ind)
%         if clstr(ic).xx >= 400 && clstr(ic).xx < 900 && clstr(ic).yy >= 400 && clstr(ic).yy < 900 
%             ind(ic) = true;
%         end
%     end
% 
%     RGB = insertText(img0(500:800, 550:850, :), [([clstr(ind).yy] - 550)', ...
%         ([clstr(ind).xx] - 500)'], [clstr(ind).value], FontSize=12, BoxColor="green",...
%         BoxOpacity=0.2, TextColor="black");
%     imtool(RGB);
end
disp(["Label Recall", 100 * tplabel / actpos]);
disp(["Label Precision", 100 * tplabel / predpos]);
disp(["Recall", 100 * tp / actpos]);
disp(["Common Precision", 100 * tp / predpos]);
disp(["Identity Precision", 100 * tp / tplabel]);
disp(["Time ", tt / (2 * nImg * sizeX * sizeY / 10 ^ 6)]);

%     target = zeros(1, numel(output));
%     for il = 1 : numel(output)
%         [dr, dc] = find(mskind(xx(il) - 4 : xx(il) + 4, yy(il) - 4 : yy(il) + 4) > 0);
%         if numel(dr) == 1
%             target(il) = mskind(xx(il) + dr - 5, yy(il) + dc - 5);
%         end
%     end

% disp(["Recall ", 100 * sum(tp) / sum(actpos)]);
% disp(["Common Precision ", 100 * sum(tp) / sum(predpos)]);
% disp(["Identity Precision ",100 * sum(tpid) / sum(predposid)]);
% disp(["Time ", tt / (nImg * sizeX * sizeY / 10 ^ 6)]);

% [~, output] = max(feature);
% disp(["Common Precision ", 100 * sum(output == target) / numel(target)]);
% disp(["Identity Precision ",100 * sum((output == target) & (output ~= 0)) / sum(target ~= 0)]);