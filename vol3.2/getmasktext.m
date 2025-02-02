function msk = getmasktext(text, point, sz, font, anchor)
msk = zeros([sz, 3], 'uint8');
for i = 1 : size(point, 1)
    msk = insertText(msk, [point(i, 2), point(i, 1)], text(i), ...
        'AnchorPoint', anchor, 'BoxOpacity', 0, 'Font', font, 'FontSize', 14, ...
        'TextColor', [255, 255, 255]);
end
msk = double(msk(:, :, 1)) / 255;
end