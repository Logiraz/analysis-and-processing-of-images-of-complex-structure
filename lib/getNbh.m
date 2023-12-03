function result = getNbh(image, points, windowSize, phi)
depth = numel(image) / (size(image, 1) * size(image, 2));
wX = windowSize(1);
wY = windowSize(1);
if numel(windowSize) == 2
    wY = windowSize(2);
end
result = zeros(depth * wX * wY, size(points, 2), [repmat('uint8', 1, depth == 3) repmat('single', 1, depth == 1)]);
[dX, dY] = meshgrid(-(wX - 1) / 2 : (wX - 1) / 2, -(wY - 1) / 2 : (wY - 1) / 2);
dX = reshape(dX, [1, wX * wY]);
dY = reshape(dY, [1, wX * wY]);
image = padarray(image, [wX, wY, 0], 0);
points(1, :) = points(1, :) + wX;
points(2, :) = points(2, :) + wY;
if numel(phi) > 1
    if depth == 3
        for i = 1 : size(points, 2)
            for j = 1 : wX * wY
                xx = round(points(1, i) + dX(j) * cos(phi(i)) - dY(j) * sin(phi(i)));
                yy = round(points(2, i) + dX(j) * sin(phi(i)) + dY(j) * cos(phi(i)));
                result(3 * j - 2 : 3 * j, i) = [image(xx, yy, 1), image(xx, yy, 2), image(xx, yy, 3)];
            end
        end
    elseif depth == 1
        for i = 1 : size(points, 2)
            for j = 1 : wX * wY
                xx = round(points(1, i) + dX(j) * cos(phi(i)) - dY(j) * sin(phi(i)));
                yy = round(points(2, i) + dX(j) * sin(phi(i)) + dY(j) * cos(phi(i)));
                result(j, i) = image(xx, yy);
            end
        end
    end
elseif numel(phi) == 1 && phi ~= 0
    if depth == 3
        for i = 1 : size(points, 2)
            for j = 1 : wX * wY
                xx = round(points(1, i) + dX(j) * cos(phi) - dY(j) * sin(phi));
                yy = round(points(2, i) + dX(j) * sin(phi) + dY(j) * cos(phi));
                result(3 * j - 2 : 3 * j, i) = [image(xx, yy, 1), image(xx, yy, 2), image(xx, yy, 3)];
            end
        end
    elseif depth == 1
        for i = 1 : size(points, 2)
            for j = 1 : wX * wY
                xx = round(points(1, i) + dX(j) * cos(phi) - dY(j) * sin(phi));
                yy = round(points(2, i) + dX(j) * sin(phi) + dY(j) * cos(phi));
                result(j, i) = image(xx, yy);
            end
        end
    end
else
    if depth == 3
        for i = 1 : size(points, 2)
            for j = 1 : wX * wY
                xx = points(1, i) + dX(j);
                yy = points(2, i) + dY(j);
                result(3 * j - 2 : 3 * j, i) = [image(xx, yy, 1), image(xx, yy, 2), image(xx, yy, 3)];
            end
        end
    elseif depth == 1
        for i = 1 : size(points, 2)
            for j = 1 : wX * wY
                xx = points(1, i) + dX(j);
                yy = points(2, i) + dY(j);
                result(j, i) = image(xx, yy);
            end
        end
    end
end
if depth == 3
    result = uint8(result);
elseif depth == 1
    result = single(result);
end
end