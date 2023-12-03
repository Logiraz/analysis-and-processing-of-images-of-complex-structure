addpath(pwd + "\lib");
folderIn = "data\seg\";
folderOut = "data\loc\";
nMaps = 20;

files = string(1 : nMaps) + "k.png";
chromosome = load("models\loc\chr_k_strict.mat").bestChromosome;
localization(folderIn, folderOut, files, chromosome);

files = string(1 : nMaps) + "b.png";
chromosome = load("models\loc\chr_b_strict.mat").bestChromosome;
localization(folderIn, folderOut, files, chromosome);