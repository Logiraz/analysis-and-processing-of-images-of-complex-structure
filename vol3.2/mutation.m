function Chromosome = mutation(oldChromosome)
names = ["dilate", "erode", "open", "close", "skel", "Area", "Eccentricity", "MajorAxisLength", "MinorAxisLength", "Orientation"];
senames = ["diamond", "disk", "square", "hline", "vline"];
Chromosome = clearChromosome(oldChromosome);
probInsert = 5 / numel(Chromosome);
probMod = 0.95 + 0.05 / numel(Chromosome);
centre = findCentromere(Chromosome);

x = rand();
if x < 0.5
    pos = ceil(rand() * centre);
else
    pos = ceil(rand() * (numel(Chromosome) - centre + 1)) + centre;
end

x = rand();
if x < probInsert
    if pos <= centre
        name = names(ceil(rand() * 4));
        if ismember(name, ["dilate", "erode", "open", "close"])
            sename = senames(ceil(rand() * numel(senames)));
            Gene = struct('name',  name, ...
                'prop', struct('name', sename, 'value', 1 + ceil(rand() * 5)));
        end
    else
        name = names(ceil(rand() * numel(names)));
        if ismember(name, ["dilate", "erode", "open", "close"])
            sename = senames(ceil(rand() * numel(senames)));
            Gene = struct('name',  name, ...
                'prop', struct('name', sename, 'value', 1 + ceil(rand() * 5)));
        end
        if name == "skel"
            Gene = struct('name', name, 'prop', struct());
        end
        if name == "Area"
            Gene = struct('name',  name, ...
                'prop', struct('value1', ceil(rand() * 10), 'value2', ceil(2 ^ (rand() * 6 + 5))));
        end
        if name == "Eccentricity"
            Gene = struct('name',  name, ...
                'prop', struct('value1', rand() * 0.1 + 0.1, 'value2', rand() * 0.2 + 0.7));
        end
        if name == "Orientation"
            Gene = struct('name',  name, ...
                'prop', struct('value1', rand() * (-45), 'value2', rand() * 45));
        end
        if ismember(name, ["MajorAxisLength", "MinorAxisLength"])
            Gene = struct('name',  name, ...
                'prop', struct('value1', rand() * 5 + 5, 'value2', rand() * 20 + 10));
        end
    end
    Chromosome = [Chromosome(1 : pos - 1), Gene, Chromosome(pos : end)];
elseif x < probMod
    if pos > numel(Chromosome)
        pos = pos - 1;
    end
    if ismember(Chromosome(pos).name, ["dilate", "erode", "open", "close"])
        if Chromosome(pos).prop.value > 2
            Chromosome(pos).prop.value = Chromosome(pos).prop.value + round(rand()) * 2 - 1;
        else
            Chromosome(pos).prop.value = Chromosome(pos).prop.value + 1;
        end
    end
    if Chromosome(pos).name == "threshold"
        Chromosome(pos).prop.value = Chromosome(pos).prop.value * 2 ^ (rand() * 0.2 - 0.1);
    end
    if Chromosome(pos).name == "Area"
        if Chromosome(pos).prop.value1 > 5
            Chromosome(pos).prop.value1 = round(Chromosome(pos).prop.value1 * 2 ^ (rand() * 2 - 1));
        else
            Chromosome(pos).prop.value1 = Chromosome(pos).prop.value1 + round(rand()) * 2 - 1;
        end
        if Chromosome(pos).prop.value2 > 5
            Chromosome(pos).prop.value2 = round(Chromosome(pos).prop.value2 * 2 ^ (rand() * 2 - 1));
        else
            Chromosome(pos).prop.value2 = Chromosome(pos).prop.value2 + round(rand()) * 2 - 1;
        end
    end
    if ismember(Chromosome(pos).name, ...
            ["Eccentricity", "MajorAxisLength", "MinorAxisLength", "Orientation"])
        Chromosome(pos).prop.value1 = Chromosome(pos).prop.value1 * 2 ^ (rand() * 0.2 - 0.1);
        Chromosome(pos).prop.value2 = Chromosome(pos).prop.value2 * 2 ^ (rand() * 0.2 - 0.1);
    end
elseif pos ~= centre
    Chromosome = [Chromosome(1 : pos - 1), Chromosome(pos + 1 : end)];
end
end