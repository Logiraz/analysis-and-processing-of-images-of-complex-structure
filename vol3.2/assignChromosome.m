function newChromosome = assignChromosome(oldChromosome, tempChromosome, i)
newChromosome = oldChromosome;
if size(tempChromosome, 2) <= size(newChromosome, 2)
    newChromosome(i, 1 : size(tempChromosome, 2)) = tempChromosome;
else
    for j = size(newChromosome, 2) + 1 : size(tempChromosome, 2)
        newChromosome(i, j) = struct('name', "", 'prop', struct());
    end
    newChromosome(i, :) = tempChromosome;
end
end