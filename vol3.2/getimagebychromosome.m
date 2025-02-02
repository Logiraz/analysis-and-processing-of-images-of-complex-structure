function img = getimagebychromosome(Chromosome, Picture)
img = Picture;
Chromosome = clearChromosome(Chromosome);
nGen = numel(Chromosome);
for i = 1 : nGen
    if ismember(Chromosome(i).name, ["dilate", "erode", "open", "close"])
        if Chromosome(i).prop.name == "hline"
            se = strel("line", Chromosome(i).prop.value, 0);
        elseif Chromosome(i).prop.name == "vline"
            se = strel("line", Chromosome(i).prop.value, 90);
        else
            se = strel(Chromosome(i).prop.name, Chromosome(i).prop.value);
        end
        img = eval("im" + Chromosome(i).name + "(img, se)");
    end
    if Chromosome(i).name == "threshold"
        img = img > Chromosome(i).prop.value;
    end
    if Chromosome(i).name == "skel"
        img = bwmorph(img, 'skel');
    end
    if ismember(Chromosome(i).name, ...
            ["Area", "Eccentricity", "MajorAxisLength", "MinorAxisLength", "Orientation"])
        img = bwpropfilt(img, Chromosome(i).name, ...
            [Chromosome(i).prop.value1 Chromosome(i).prop.value2]);
    end
end
end