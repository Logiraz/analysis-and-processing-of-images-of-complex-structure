nMaps = 20;
folderIn = "data\cut\";
folderOut = "data\map\";
files = string(1 : nMaps) + ".png";

% Преобразование ЦТК №1-5 (1 : 50 000) с 200 dpi в 300 dpi
% Преобразование ЦТК №6-13 не требуется, так как к их формату приводятся остальные
% Преобразование ЦТК №14-20 (1 : 25 000) с 250 dpi в 300 dpi с компенсацией изменения масштаба
scale = [1.5 * ones(1, 5), ones(1, 8), 0.93 * ones(1, 7)];
resizeMaps(folderIn, folderOut, files, scale);