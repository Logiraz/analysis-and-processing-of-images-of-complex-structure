function [map, z] = GetMap(maxstep)
arguments
    maxstep (1, 1) {mustBeNumeric} = 10;
end
sz = 2 ^ (maxstep - 1) - 1;
map = zeros(sz, sz, 3, 'uint8');
z = GenDEM([0, 0.7; 0, 0], maxstep, 0);
map = FillByMask(map, z == 0, [251, 244, 190], 1);
% line20 = diff(z) .* (z == 20 || z == 21);
% map = AddBlue(map, z);

imtool(map);
end