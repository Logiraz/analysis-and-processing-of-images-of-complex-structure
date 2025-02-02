function Chromosome = crossover(Chromosome1, Chromosome2)
ind1 = findCentromere(Chromosome1);
ind2 = findCentromere(Chromosome2);
if rand() < 0.5
    Chromosome = [Chromosome1(1 : ind1), Chromosome2(ind2 + 1 : end)];
else
    Chromosome = [Chromosome2(1 : ind2), Chromosome1(ind1 + 1 : end)];
end
Chromosome = clearChromosome(Chromosome);
end