function ff = fitnessfunction(Chromosome, Child, Parent, Picture, PictureIdeal, PictureCrit)
ff = zeros(numel(Child), 1);
nCrit = 0.95 * sum(PictureCrit, "all");

for i = 1 : numel(Child)
    newImage = getimagebychromosome(Chromosome(Child(i), :), Picture);
    if Parent(i) == 0
        oldImage = false(size(Picture));
    else
        oldImage = getimagebychromosome(Chromosome(Parent(i), :), Picture);
    end
    minCrit = min(sum(oldImage & PictureCrit, "all"), nCrit);
    ff(i) = (sum(newImage & PictureCrit, "all") >= minCrit) * ...
        sum(newImage & PictureCrit, "all") / nCrit * ...
        sum(newImage & PictureIdeal, "all") / sum(newImage | PictureIdeal, "all");
end
end