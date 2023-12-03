function [ff, ff2] = fitnessFunction(chromosome, child, parent, picture, pictureIdeal, pictureCrit, strictness)
ff = zeros(numel(child), 1);
ff2 = zeros(numel(child), 1);
levelCrit = 1.00;

for i = 1 : numel(child)
    for j = 1 : numel(picture)
        newImage = applyChromosome(chromosome(child(i), :), picture{j});
        if parent(i) == 0
            oldImage = false(size(picture{j}));
        else
            oldImage = applyChromosome(chromosome(parent(i), :), picture{j});
        end
        nCrit = levelCrit * sum(pictureCrit{j}, "all");
        minCrit = min(sum(oldImage & pictureCrit{j}, "all"), nCrit);
        if strictness & sum(newImage & pictureCrit{j}, "all") < minCrit
            ff(i) = 0;
            ff2(i) = 0;
            break;
        end
        ff(i) = ff(i) + (sum(newImage & pictureCrit{j}, "all") >= minCrit) * ...
            sum(newImage & pictureCrit{j}, "all") / nCrit * ...
            sum(newImage & pictureIdeal{j}, "all") / sum(newImage | pictureIdeal{j}, "all");
        ff2(i) = ff2(i) + sum(newImage & pictureCrit{j}, "all") / sum(pictureCrit{j}, "all");
    end
    ff(i) = ff(i) / numel(picture);
    ff2(i) = ff2(i) / numel(picture);
end
end