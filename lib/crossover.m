function chromosome = crossover(chromosome1, chromosome2)
ind1 = findCentromere(chromosome1);
ind2 = findCentromere(chromosome2);
if rand() < 0.5
    chromosome = [chromosome1(1 : ind1), chromosome2(ind2 + 1 : end)];
else
    chromosome = [chromosome2(1 : ind2), chromosome1(ind1 + 1 : end)];
end
chromosome = clearChromosome(chromosome);
end