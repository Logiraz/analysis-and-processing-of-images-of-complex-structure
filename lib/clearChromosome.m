function newChromosome = clearChromosome(oldChromosome)
newChromosome = oldChromosome;
for i = numel(newChromosome) : -1 : 1
    if numel(newChromosome(i).name) == 0
        newChromosome(i) = [];
    else
        break;
    end
end
end