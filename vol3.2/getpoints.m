function [x, y] = getpoints(init_msk, init_n, rad, edge)
msk = padarray(init_msk(edge + 1 : end - edge, edge + 1 : end - edge), [edge, edge], 0);
n = init_n;
flag = 5;
x = [];
y = [];
while flag > 0
    n_prob = ceil(sum(msk, "all") / (4 * rad * rad));
    [xx, yy] = find(msk);
    if numel(xx) == 0
        break;
    end
    ind = randperm(numel(xx), n_prob);
    d = pdist2([xx(ind), yy(ind)], [xx(ind), yy(ind)]);
    [f, s] = find(d < rad);
    ind_del = ind * 0;
    for i = 1 : numel(f)
        if f(i) < s(i)
            ind_del(f(i)) = 1;
            ind_del(s(i)) = 1;
        end
    end
    ind = ind(~ind_del);
    if numel(ind) == 0
        flag = flag - 1;
    else
        if n < numel(ind)
            ind = ind(1 : n);
        end
        x = [x; xx(ind)];
        y = [y; yy(ind)];
        n = n - numel(ind);
        if n > 0
            flag = 5;
        else
            flag = 0;
        end
        msk_del = msk * 0;
        msk_del(sub2ind(size(init_msk), xx(ind), yy(ind))) = 1;
        msk_del = imdilate(msk_del, strel('square', rad));
        msk = msk & ~msk_del;
    end
end
% disp("");
end