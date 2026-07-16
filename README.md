This repository contains data and analysis scripts accompanying the manuscript. It is organised into two subfolders: exp1 (Experiment 1, fMRI) and exp2 (Experiment 2, TUS). MATLAB (.m) files are used for data preprocessing; behavioural analyses are performed in R and provided as R Markdown (.Rmd) files to be run in RStudio. All datasets are located in the same folder as their corresponding analysis scripts.


System Requirements:


R (≥ 4.1) and RStudio (≥ 2022.07): required for behavioural analysis

MATLAB (≥ R2020a): required for data preprocessing

Tested on macOS (Monterey and above) 

No non-standard hardware required



Installation:

Install R from https://cran.r-project.org and RStudio from https://posit.co/download/rstudio-desktop. Then install required R packages.
Typical install time: 5–10 minutes. 


Demo and Instructions for Use:

To run the behavioural analysis, open the .Rmd file in the relevant subfolder (exp1/ or exp2/) in RStudio and run sections interactively. To run preprocessing, open and run the .m file in MATLAB. Expected outputs correspond to the figures and statistical results reported in the main text.


Data Availability:


Behavioural data and scripts: https://github.com/shuyil/causalInf
Whole-brain statistical images: https://neurovault.org/collections/HIIMHDBP/
Neuroimaging data: available from the corresponding author upon reasonable request
