function [mskfull, mskcenter] = getgamask(sizes, data)
% mskfull = false(sizes);
mskcenter = false(sizes);
for i = 1 : size(data, 1)
%     x = data(i, 2);
%     y = data(i, 3);
%     h2 = (data(i, 8) - 1) / 2 - 2;
%     w2 = (data(i, 9) - 1) / 2 - 2;
%     mskfull(x - h2 : x + h2, y - w2 : y + w2) = true;
%     mskcenter(x, y) = true;
    x = data(i, 2);
    y = data(i, 7);
    mskcenter(x, y) = true;
    if data(i, 4) ~= -1
        y = data(i, 5);
        mskcenter(x, y) = true;
    end
end
mskfull = imdilate(mskcenter, strel("square", 7));
end