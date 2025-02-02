nImg = 10;
for seed = 0 : 2 * nImg - 1
    disp(seed);

    rng(seed);
    maxstep = 10;
    z = gendem([0, 0; 0, 0], maxstep, seed);
    z = imresize(z, 4, 'bilinear');
    map = ones(size(z, 1), size(z, 2), 3, 'uint8') * 255;
    mskblack = z * 0;
    data = [];
    scale = 100;

    % Земля
    map = fillbymask(map, floor(z * scale) == 0, [251, 244, 190], 1);

    % Изобаты
    ib50 = getisobath(z, scale, 50);
    ib20 = getisobath(z, scale, 20);
    ib10 = getisobath(z, scale, 10);
    ib05 = getisobath(z, scale, 5);
    ib00 = getisobath(z, scale, 0);

    % Голубое под изобатами
    msk = floor(z * 100) <= 20;
    msk = msk & ~imerode(msk, strel('disk', 8));
    msk = msk & ~ib20;
    msk = bwareaopen(msk, 3, 4);
    msk = msk | bwareaopen(floor(z * scale) <= 10 & ~ib10 & floor(z * scale) > 0, 3, 4);
    msk = msk & (z > 0);
    map = fillbymask(map, msk, [193, 224, 244], 1);
    clear msk;

    % Размещение отметок
    load label.mat;
    se = strel('disk', 15);
    blk = imdilate(floor(z * scale) == 0, se);
    lbl = blk * 0;

    % Банки: значения, голубое, точки, названия
    msk = ~blk;
    rad = 200;
    [xx, yy] = getpoints(msk, floor(sum(msk, "all") / (4 * rad * rad * 0.1)), rad, 20);
    value = floor(z(sub2ind(size(z), xx, yy)) * scale / 2);
    ind = value < 20;
    [msk, datanew] = getmasknum(value(ind), [xx(ind), yy(ind)], size(z));
    data = [data; datanew];
    lbl = lbl | msk;
    blk = blk | imdilate(msk > 0, se);
    msk2 = msk * 0;
    msk2(sub2ind(size(z), xx(ind), yy(ind))) = 1;
    msk2 = imdilate(msk2, strel('disk', 9));
    map = fillbymask(map, msk2, [193, 224, 244], 1);
    map = fillbymask(map, msk, [0, 0, 0], 1);
    mskblack = mskblack + msk;
    msk = getmaskbank([xx(ind), yy(ind)], size(z));
    map = fillbymask(map, msk, [0, 0, 0], 1);
    text = strings(1, sum(ind));
    load names;
    for i = 1 : numel(text)
        text(i) = compose("б-ка\n" + names(randi(500)));
    end
    msk = getmasktext(text, [xx(ind), yy(ind) + 5], size(z), 'D431 Italic', 'LeftCenter');
    lbl = lbl | msk;
    blk = blk | imdilate(msk > 0, se);
    map = fillbymask(map, msk, [0, 0, 0], 1);
    mskblack = mskblack + msk;
    clear rad xx yy msk msk2 ind text;

    % Камни
    msk = (floor(z * scale) <= 10) & ~blk;
    rad = max(size(stone)) * 2;
    [xx, yy] = getpoints(msk, floor(sum(msk, "all") / (4 * rad * rad * 1)), rad, rad);
    msk = getmask(stone, [xx, yy], size(z));
    lbl = lbl | msk;
    blk = blk | imdilate(msk, se);
    map = fillbymask(map, msk, [0, 0, 0], 1);
    mskblack = mskblack + msk;
    clear rad xx yy msk;

    % Затонувшие корабли
    msk = (floor(z * scale) <= 20) & ~blk;
    rad = max(size(ship)) * 2;
    [xx, yy] = getpoints(msk, floor(sum(msk, "all") / (4 * rad * rad * 1)), rad, rad);
    msk = getmask(ship, [xx, yy], size(z));
    lbl = lbl | msk;
    blk = blk | imdilate(msk, se);
    map = fillbymask(map, msk, [0, 0, 0], 1);
    mskblack = mskblack + msk;
    clear rad xx yy msk;

    % Грунты
    msk = ~blk;
    rad = 200;
    [xx, yy] = getpoints(msk, floor(sum(msk, "all") / (4 * rad * rad * 0.3)), rad, 30);
    soils = ["мП", "сП", "кП", "И", "Гл", "К", "Ск", "Гк", "Гр"];
    text = strings(1, numel(xx));
    for i = 1 : numel(xx)
        text(i) = strjoin(soils(randperm(numel(soils), floor(rand() * 2 + 1))), '');
    end
    msk = getmasktext(text, [xx, yy], size(z), 'D431 Italic', 'Center');
    lbl = lbl | msk;
    blk = blk | imdilate(msk > 0, se);
    map = fillbymask(map, msk, [0, 0, 0], 1);
    mskblack = mskblack + msk;
    clear rad xx yy msk;

    % Отметки глубин
    msk = ~(blk | imdilate(ib50 + ib20 + ib10 + ib05, strel('disk', 5)));
    rad = 100;
    [xx, yy] = getpoints(msk, floor(sum(msk, "all") / (4 * rad * rad * 0.01)), rad, 20);
    value = floor(z(sub2ind(size(z), xx, yy)) * scale);
    [msk, datanew] = getmasknum(value, [xx, yy], size(z));
    data = [data; datanew];
    lbl = lbl | msk;
    blk = blk | imdilate(msk > 0, se);
    map = fillbymask(map, msk, [0, 0, 0], 1);
    mskblack = mskblack + msk;
    clear rad xx yy msk;

    lbl = imdilate(lbl, strel('disk', 2)); % для непересечения ТО с ЛО

    % Сетка
    grdsz = 400;
    grd = zeros(size(z, 1) + grdsz, size(z, 2) + grdsz);
    grd(1 : grdsz : end, :) = 1;
    grd(:, 1 : grdsz : end) = 1;
    grd = grd(randi(grdsz) : end, randi(grdsz) : end);
    grd = grd(1 : size(z, 1), 1 : size(z, 2));
    map = fillbymask(map, grd & ~lbl, [0, 0, 0], 1);
    mskblack = mskblack + (grd & ~lbl);
    clear grd grdsz;

    % Рисование линейных объектов
    map = fillbymask(map, imdilate(ib00, strel('square', 2)) & ~lbl, [0, 0, 0], 1);
    mskblack = mskblack + (imdilate(ib00, strel('square', 2)) & ~lbl);
    map = fillbymask(map, (ib50 + ib20 + ib10 + ib05) & ~lbl, [0, 0, 0], 1); % [109, 124, 170]
    mskblack = mskblack + ((ib50 + ib20 + ib10 + ib05) & ~lbl);
    mskblack = mskblack > 0.5;

    map = imgaussfilt(map, 0.5);
    map = imnoise(map, 'speckle', 0.01);
    % imtool(map);

    imwrite(map, "train\img_" + string(seed) + ".jpg");
    save("train\data_" + string(seed) + ".mat", 'mskblack', 'data');
end