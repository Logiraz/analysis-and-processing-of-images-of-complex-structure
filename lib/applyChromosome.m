function image = applyChromosome(chromosome, picture)
image = picture;
chromosome = clearChromosome(chromosome);
nGen = numel(chromosome);
for i = 1 : nGen
    if ismember(chromosome(i).name, ["dilate", "erode", "open", "close"])
        if chromosome(i).prop.name == "hline"
            se = strel("line", chromosome(i).prop.value, 0);
        elseif chromosome(i).prop.name == "vline"
            se = strel("line", chromosome(i).prop.value, 90);
        else
            se = strel(chromosome(i).prop.name, chromosome(i).prop.value);
        end
        image = eval("im" + chromosome(i).name + "(image, se)");
    end
    if chromosome(i).name == "threshold"
        image = image > chromosome(i).prop.value;
    end
    if chromosome(i).name == "skel"
        image = bwmorph(image, 'skel');
    end
    if ismember(chromosome(i).name, ...
            ["Area", "Eccentricity", "MajorAxisLength", "MinorAxisLength", "Orientation"])
        image = bwpropfilt(image, chromosome(i).name, ...
            [chromosome(i).prop.value1 chromosome(i).prop.value2]);
    end
end
image = logical(image);
end