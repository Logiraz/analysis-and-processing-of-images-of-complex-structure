rng(0);
nImg = 10;

% for i = 0 : 0%nImg - 1
%     rng(i);
%     data = load("train\data_" + string(i) + ".mat").data;
%     img = imread("train\seg_" + string(i) + ".png");
%     img = single(img) / 255;
%     sizeX = size(img, 1);
%     sizeY = size(img, 2);
% 
%     [mskf, mskc] = getgamask([sizeX, sizeY], data);
%     chromosome = geneticalgorithm(img, mskf, mskc);
% end

% tt = 0;
for i = 0 : 2 * nImg - 1
    data = load("train\data_" + string(i) + ".mat").data;
    img = imread("train\seg_" + string(i) + ".png");
    img = single(img) / 255;
    sizeX = size(img, 1);
    sizeY = size(img, 2);

    [mskf, mskc] = getgamask([sizeX, sizeY], data);
%     tic
    img2 = getimagebychromosome(chromosome, img);
    imwrite(img2, "train\ga_" + string(i) + ".png");
%     tt = tt + toc;
%     FF(i + 1) = fitnessfunction(chromosome, 1, 0, img, mskf, mskc);
%     Recall(i + 1) = sum(img2 & mskc, "all") / sum(mskc, "all");
%     otn(i + 1) = sum(imclose(img, strel("square", 7)) > 0.5, "all") / sum(img2, "all");
%     disp([i, FF(i + 1), Recall(i + 1)]);
%     disp(otn(i + 1));
end
% disp([mean(FF), std(FF)])
% disp([mean(Recall), std(Recall)])
% disp(tt);
% disp([mean(otn), std(otn)])