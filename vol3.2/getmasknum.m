function [msk, data] = getmasknum(val, point, sz)
data = zeros(size(point, 1), 9);
data(:, 1) = val;
data(:, 2) = point(:, 1);
data(:, 3) = point(:, 2);
img = load('numbers.mat').img;
msk = zeros(sz);
for i = 1 : size(point, 1)
    if val(i) >= 10
        d1 = floor(val(i) / 10);
        data(i, 4) = d1;
        ind1 = randi(500) + d1 * 500;
        s = 2 + randi(4);
        data(i, 5) = point(i, 2) - s;
        msk(point(i, 1) - 6 : point(i, 1) + 6, point(i, 2) - 5 - s : point(i, 2) + 5 - s) = ...
            msk(point(i, 1) - 6 : point(i, 1) + 6, point(i, 2) - 5 - s : point(i, 2) + 5 - s) + img(:, :, ind1);
        d0 = mod(val(i), 10);
        data(i, 6) = d0;
        data(i, 7) = point(i, 2) + s;
        data(i, 8) = 13;
        data(i, 9) = 11 + 2 * s;
        ind0 = randi(500) + d0 * 500;
        msk(point(i, 1) - 6 : point(i, 1) + 6, point(i, 2) - 5 + s : point(i, 2) + 5 + s) = ...
            msk(point(i, 1) - 6 : point(i, 1) + 6, point(i, 2) - 5 + s : point(i, 2) + 5 + s) + img(:, :, ind0);
    else
        d0 = val(i);
        data(i, 4) = -1;
        data(i, 5) = -1;
        data(i, 6) = d0;
        data(i, 7) = point(i, 2);
        data(i, 8) = 13;
        data(i, 9) = 11;
        ind0 = randi(500) + d0 * 500;
        msk(point(i, 1) - 6 : point(i, 1) + 6, point(i, 2) - 5 : point(i, 2) + 5) = ...
            msk(point(i, 1) - 6 : point(i, 1) + 6, point(i, 2) - 5 : point(i, 2) + 5) + img(:, :, ind0);
    end
end
msk = msk * 1.5;
msk(msk > 1) = 1;
end