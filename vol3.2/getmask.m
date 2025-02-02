function msk = getmask(img, point, sz)
rx = floor(size(img, 1) / 2);
ry = floor(size(img, 2) / 2);
msk = zeros(sz);
for i = 1 : size(point, 1)
    msk(point(i, 1) - rx : point(i, 1) + rx, point(i, 2) - ry : point(i, 2) + ry) = ...
        msk(point(i, 1) - rx : point(i, 1) + rx, point(i, 2) - ry : point(i, 2) + ry) | img; 
end
end