function BestChromosome = geneticalgorithm(Picture, PictureIdeal, PictureCrit)
PopulationSize = 100;
AcceptableScore = 0.9;
MaxIteration = 100;
ElitePart = 0.3;
ProbCrossover = 0.1;

Parent = zeros(PopulationSize, 1);
Chromosome(PopulationSize, 1) = struct('name',  "none", 'prop', struct());
for i = 1 : PopulationSize
    Chromosome(i, 1) = struct('name',  "threshold", ...
        'prop', struct('value', rand() * 0.2 + 0.4));
end
FF = fitnessfunction(Chromosome, 1 : PopulationSize, Parent, Picture, PictureIdeal, PictureCrit);
[~, sortIdx] = sort(FF, "descend");
Chromosome = Chromosome(sortIdx, :);
FF = FF(sortIdx);
Iteration = 0;
while Iteration < MaxIteration
    NewChromosome = Chromosome(1 : ceil(PopulationSize * ElitePart), :);
    maxsize = 0;
    for i = 1 : ceil(PopulationSize * ElitePart)
        if numel(clearChromosome(NewChromosome(i, :))) > maxsize
            maxsize = numel(clearChromosome(NewChromosome(i, :)));
        end
    end
    NewChromosome = NewChromosome(:, 1 : maxsize);

    newPopulation = ceil(PopulationSize * ElitePart) + 1 : PopulationSize;
    for i = newPopulation
        Parent1 = ceil(rand() * PopulationSize * ElitePart);
        if rand() < ProbCrossover
            Parent2 = ceil(rand() * PopulationSize * ElitePart);
            tempChromosome = crossover(Chromosome(Parent1, :), Chromosome(Parent2, :));
            NewChromosome = assignChromosome(NewChromosome, tempChromosome, i);
            Parent(i) = (FF(Parent1) > FF(Parent2)) * (Parent1 - Parent2) + Parent2;
        else
            tempChromosome = mutation(Chromosome(Parent1, :));
            NewChromosome = assignChromosome(NewChromosome, tempChromosome, i);
            Parent(i) = Parent1;
        end
    end
    Chromosome = NewChromosome;
    FF(newPopulation) = fitnessfunction(Chromosome, newPopulation, Parent(newPopulation), Picture, PictureIdeal, PictureCrit);
    [~, sortIdx] = sort(FF, "descend");
    Chromosome = Chromosome(sortIdx, :);
    Parent = Parent(sortIdx);
    FF = FF(sortIdx);
    if FF(1) > AcceptableScore
        break
    end
    BestChromosome = clearChromosome(Chromosome(1, :));
    disp([Iteration, numel(BestChromosome), FF(1) ...
        sum(getimagebychromosome(BestChromosome, Picture) & PictureCrit, "all") / sum(PictureCrit, "all")]);
    save('bestch.mat', 'BestChromosome');
    Iteration = Iteration + 1;
end
end