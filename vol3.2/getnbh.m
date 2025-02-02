function Result = getnbh(Picture, Points, a, phi)
depth = numel(Picture) / (size(Picture, 1) * size(Picture, 2));
ax = a(1);
ay = a(1);
if numel(a) == 2
    ay = a(2);
end
Result = zeros(depth * ax * ay, size(Points, 2), [repmat('uint8', 1, depth == 3) repmat('double', 1, depth == 1)]);
[dx, dy] = meshgrid(-(ax - 1) / 2 : (ax - 1) / 2, -(ay - 1) / 2 : (ay - 1) / 2);
dx = reshape(dx, [1, ax * ay]);
dy = reshape(dy, [1, ax * ay]);
Picture = padarray(Picture, [ax, ay, 0], 0);
Points(1, :) = Points(1, :) + ax;
Points(2, :) = Points(2, :) + ay;
if phi ~= 0
    for i = 1 : size(Points, 2)
        for j = 1 : ax * ay
            cx = round(Points(1, i) + dx(j) * cos(phi) - dy(j) * sin(phi));
%             cx(cx < 1) = 1;
%             cx(cx > size(Picture, 1)) = size(Picture, 1);
            cy = round(Points(2, i) + dx(j) * sin(phi) + dy(j) * cos(phi));
%             cy(cy < 1) = 1;
%             cy(cy > size(Picture, 2)) = size(Picture, 2);
            if depth == 3
                Result(3 * j - 2 : 3 * j, i) = [Picture(cx, cy, 1), Picture(cx, cy, 2), Picture(cx, cy, 3)];
            elseif depth == 1
                Result(j, i) = Picture(cx, cy);
            end
        end
    end
else
    for i = 1 : size(Points, 2)
        for j = 1 : ax * ay
            cx = Points(1, i) + dx(j);
%             cx(cx < 1) = 1;
%             cx(cx > size(Picture, 1)) = size(Picture, 1);
            cy = Points(2, i) + dy(j);
%             cy(cy < 1) = 1;
%             cy(cy > size(Picture, 2)) = size(Picture, 2);
            if depth == 3
                Result(3 * j - 2 : 3 * j, i) = [Picture(cx, cy, 1), Picture(cx, cy, 2), Picture(cx, cy, 3)];
            elseif depth == 1
                Result(j, i) = Picture(cx, cy);
            end
        end
    end
end

