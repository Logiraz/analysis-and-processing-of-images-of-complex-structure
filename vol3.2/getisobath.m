function ib = getisobath(z, scale, level)
msk = floor(z * scale);
tx = diff(msk, 1, 1);
tx = (padarray(tx, [1, 0], 'replicate', 'post') + padarray(tx, [1, 0], 'replicate', 'pre')) .* discretize(msk, [level - 3, level]);
ty = diff(msk, 1, 2);
ty = (padarray(ty, [0, 1], 'replicate', 'post') + padarray(ty, [0, 1], 'replicate', 'pre')) .* discretize(msk, [level - 3, level]);
ib = (abs(tx) + abs(ty)) > 0;
[rr, cc] = find(ib ~= 0);
ind = (rr > 1) & (cc > 1) & (rr < size(z, 1)) & (cc < size(z, 2));
for i = 1 : numel(rr)
    if ind(i)
        tt = find(msk(rr(i) - 1 : rr(i) + 1, cc(i) - 1 : cc(i) + 1) > level);
        if numel(tt) == 0
            ib(rr(i), cc(i)) = 0;
        end
    end
end
ib = bwmorph(ib, 'skel', Inf);
% ib = bwareaopen(ib, 10, 8);
end