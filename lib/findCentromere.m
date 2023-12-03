function ind = findCentromere(chromosome)
for i = 1 : numel(chromosome)
    if numel(chromosome(i).name) > 0
        if chromosome(i).name == "threshold"
            ind = i;
            break;
        end
    end
end
end