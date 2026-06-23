clear all;
PATH = setPATH();
addpath(genpath(PATH.root))

corr = 1;

% Read in data
subNos = [2,3,4,5,6,7,8,9,10,11,12,14,15,17,18,19,20,23,24,25,26,28,29,30,31,32,33,34,35,36,37,38];
%subNos = [38];

nsub = numel(subNos);
DF = load_ci_data(subNos, PATH, corr);

for s = 1:nsub
    age(s) = DF{s, 1}.individual.age;
    gender{s} = DF{s, 1}.individual.gender;
end