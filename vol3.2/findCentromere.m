function ind = findCentromere(Chromosome)
for i = 1 : numel(Chromosome)
    if numel(Chromosome(i).name) > 0
        if Chromosome(i).name == "threshold"
            ind = i;
            break;
        end
    end
end
end