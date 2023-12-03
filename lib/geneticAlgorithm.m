function geneticAlgorithm(picture, pictureIdeal, pictureCrit, strictness)
populationSize = 200;
acceptableScore = 0.9;
maxIteration = 100;
elitePart = 0.3;
crossoverProb = 0.1;

parent = zeros(populationSize, 1);
chromosome = arrayfun(@(r) struct("name",  "threshold", "prop", struct("value", r * 0.2 + 0.4)), ...
                           rand(populationSize, 1));
[FF, FF2] = fitnessFunction(chromosome, 1 : populationSize, parent, picture, pictureIdeal, pictureCrit, strictness);
[~, sortIdx] = sort(FF, "descend");
chromosome = chromosome(sortIdx, :);
FF = FF(sortIdx);
FF2 = FF2(sortIdx);
i = 0;
while i < maxIteration
    tic
    NewChromosome = chromosome(1 : ceil(populationSize * elitePart), :);
    maxsize = 0;
    for iC = 1 : ceil(populationSize * elitePart)
        if numel(clearChromosome(NewChromosome(iC, :))) > maxsize
            maxsize = numel(clearChromosome(NewChromosome(iC, :)));
        end
    end
    NewChromosome = NewChromosome(:, 1 : maxsize);

    newPopulation = ceil(populationSize * elitePart) + 1 : populationSize;
    for iC = newPopulation
        Parent1 = ceil(rand() * populationSize * elitePart);
        if rand() < crossoverProb
            Parent2 = ceil(rand() * populationSize * elitePart);
            tempChromosome = crossover(chromosome(Parent1, :), chromosome(Parent2, :));
            NewChromosome = assignChromosome(NewChromosome, tempChromosome, iC);
            parent(iC) = (FF(Parent1) > FF(Parent2)) * (Parent1 - Parent2) + Parent2;
        else
            tempChromosome = mutation(chromosome(Parent1, :));
            NewChromosome = assignChromosome(NewChromosome, tempChromosome, iC);
            parent(iC) = Parent1;
        end
    end
    chromosome = NewChromosome;
    [FF(newPopulation), FF2(newPopulation)] = fitnessFunction(chromosome, newPopulation, ...
        parent(newPopulation), picture, pictureIdeal, pictureCrit, strictness);
    [~, sortIdx] = sort(FF, "descend");
    chromosome = chromosome(sortIdx, :);
    parent = parent(sortIdx);
    FF = FF(sortIdx);
    FF2 = FF2(sortIdx);
    if FF(1) > acceptableScore
        break
    end
    bestChromosome = clearChromosome(chromosome(1, :));
    disp([i, numel(bestChromosome), FF(1), FF2(1), toc / 60]);
    save('bestch.mat', 'bestChromosome');
    i = i + 1;
end
end