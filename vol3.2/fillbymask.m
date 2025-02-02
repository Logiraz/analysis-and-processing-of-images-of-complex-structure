function map_new = fillbymask(map, msk, color, alpha)
map = double(map);
color = permute(color, [3, 1, 2]);
map_new = map .* (1 - msk * alpha) + (msk .* color) * alpha;
map_new = uint8(map_new);
end