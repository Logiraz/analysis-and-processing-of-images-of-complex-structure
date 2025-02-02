function z = gendem(init_z, maxstep, seed)
arguments
    init_z (2, 2) double = [0, 0; 0, 0]
    maxstep {mustBeNumeric} = 10
    seed {mustBeNumeric} = 0
end
rng(seed);
% x = [0, 1; 0, 0];
x = single(init_z);
prm = 0.618;
% maxstep = 13;
range = 0.7; 
for step = 2 : maxstep
    t = padarray(x, [1, 1], 'replicate', 'both');
    n = size(t, 1);
    y = zeros(2 * n - 3, 2 * n - 3, 'single');
    i = 2 : n - 1;
    y(2 * i - 2, 2 * i - 2) = t(i, i);
    n = size(y, 1);
    i = 3 : 2 : n - 2;
    y(i, i) = (y(i - 1, i - 1) + y(i + 1, i + 1) + y(i + 1, i - 1) + y(i - 1, i + 1)) * 0.25 + ...
        2 * range * rand(numel(i), 'single') - range;
    y(:, 1) = y(:, 3);
    y(:, end) = y(:, end - 2);
    y(1, :) = y(3, :);
    y(end, :) = y(end - 2, :);
    i = 2 : 2 : n - 1;
    j = 3 : 2 : n - 2;
    y(i, j) = (y(i - 1, j) + y(i + 1, j) + y(i, j - 1) + y(i, j + 1)) * 0.25 + ...
        2 * range * rand([numel(i), numel(j)], 'single') - range;
    i = 3 : 2 : n - 2;
    j = 2 : 2 : n - 1;
    y(i, j) = (y(i - 1, j) + y(i + 1, j) + y(i, j - 1) + y(i, j + 1)) * 0.25 + ...
        2 * range * rand([numel(i), numel(j)], 'single') - range;
    x = y(2 : end - 1, 2 : end - 1);   
    range = range * prm; 
end
x = x(2 : end - 1, 2 : end - 1);
clear t y i j prm step range n;

adds = floor(0.2 * min(size(x, 1), size(x, 2)));
h = zeros(size(x, 1) + 2 * adds, size(x, 2) +  2 * adds, 'single');
rad = zeros(3, 1);
gaus = zeros(2 * adds + 1, 2 * adds + 1, 3, 'single');
for j = 1 : 3
    rad(j) = floor(adds * (7 - j) / 6);
    gaus(1 : 2 * rad(j) + 1, 1 : 2 * rad(j) + 1, j) = ...
        fspecial('gaussian', 2 * rad(j) + 1, rad(j) / 3);
    gaus(:, :, j) = gaus(:, :, j) / max(max(gaus(:, :, j)));
end
for i = 1 : (3 ^ (maxstep - 9))
    rx = floor(rand() * size(x, 1)) + adds + 1;
    ry = floor(rand() * size(x, 2)) + adds + 1;
    j = ceil(rand() * 3);
    h(rx - rad(j) : rx + rad(j), ry - rad(j) : ry + rad(j)) = ...
        h(rx - rad(j) : rx + rad(j), ry - rad(j) : ry + rad(j)) + ...
        rand() * gaus(1 : 2 * rad(j) + 1, 1 : 2 * rad(j) + 1, j);
end
h = h / max(max(h));
h = h(adds : end - adds - 1, adds : end - adds - 1);
x = x - 0.5 * h;

% rad = 10;
% h = zeros(size(x, 1) + 2 * rad, size(x, 2) +  2 * rad, 'single');
% gaus = [];
% gaus(1 : 2 * rad + 1, 1 : 2 * rad + 1) = ...
%         fspecial('gaussian', 2 * rad + 1, rad / 3);
% gaus = gaus / max(max(gaus));
% for i = 1 : (3 ^ (maxstep - 6))
%     rx = floor(rand() * size(x, 1)) + rad + 1;
%     ry = floor(rand() * size(x, 2)) + rad + 1;
%     h(rx - rad : rx + rad, ry - rad : ry + rad) = ...
%         h(rx - rad : rx + rad, ry - rad : ry + rad) + ...
%         rand() * gaus(1 : 2 * rad + 1, 1 : 2 * rad + 1);
% end
% h = h / max(max(h));
% h = h(rad : end - rad - 1, rad : end - rad - 1);
% x = x + 0.5 * h;

%x = imdilate(x, strel('disk', 10));
x = medfilt2(x, [10 10], 'symmetric');
x = (x - min(min(x))) / (max(max(x)) - min(min(x)));
x = x / quantile(x, 0.9, 'all');
x(x > 1) = 1;
z =  1 - x;
end