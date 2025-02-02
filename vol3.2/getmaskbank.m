function msk = getmaskbank(point, sz)
msk = zeros(sz);
for i = 1 : size(point, 1)
    for j = 1 : 16
        dx = round(9 * cos(2 * pi * j / 16 + 1 / 32));
        dy = round(9 * sin(2 * pi * j / 16 + 1 / 32));
        msk(point(i, 1) + dx, point(i, 2) + dy) = 1;
    end
end
end