
# Graphs
#----------------------------------------------------------------

# working directory

setwd("C:/Users/BERRAK/Desktop/BPNLab/Watermaze/Analysis")

# First load the data

library(R.matlab)

meanEloc_fm_cont  = readMat("C:/Users/BERRAK/Desktop/BPNLab/Watermaze/Analysis/Tables/AverageOverEloc/meanEloc_fm_cont.mat");
meanEloc_fm_pat   = readMat("C:/Users/BERRAK/Desktop/BPNLab/Watermaze/Analysis/Tables/AverageOverEloc/meanEloc_fm_pat.mat");
rot_meanEloc_fm_c = readMat("C:/Users/BERRAK/Desktop/BPNLab/Watermaze/Analysis/Tables/AverageOverEloc/Rotation/rot_meanEloc_fm_c.mat");
rot_meanEloc_fm_p = readMat("C:/Users/BERRAK/Desktop/BPNLab/Watermaze/Analysis/Tables/AverageOverEloc/Rotation/rot_meanEloc_fm_p.mat");


# convert it to matrix 

meanEloc_fm_cont  = matrix(unlist(meanEloc_fm_cont), ncol = 4, byrow = FALSE)
meanEloc_fm_pat   = matrix(unlist(meanEloc_fm_pat), ncol = 4, byrow = FALSE)
rot_meanEloc_fm_c = matrix(unlist(rot_meanEloc_fm_c), ncol = 4, byrow = FALSE)
rot_meanEloc_fm_p = matrix(unlist(rot_meanEloc_fm_p), ncol = 4, byrow = FALSE)




# 1. Encoding
#-------------------------
  
# extract the interested vectors from  the data
e_patients_m = meanEloc_fm_pat[,1]; # encoding-patients-MoBI
e_controls_m = meanEloc_fm_cont[,1]; # encoding-controls-MoBI
e_patients_d = meanEloc_fm_pat[,2]; # encoding-patients-Desktop
e_controls_d = meanEloc_fm_cont[,2]; # encoding-controls-Desktop

# congregate them into one vector
encoding = c(e_patients_m, e_controls_m, e_patients_d, e_controls_d)


# library
library(ggplot2)
library(tidyverse)
library(hrbrthemes)
library(viridis)

# create a data frame
conditions = rep(c("MoBI", "Desktop"), each=20);
groups     = rep(c("Patients", "Controls"), each=10);
data_enc   = data.frame(conditions, groups, encoding);

# grouped boxplot
ggplot(data_enc, aes(x=conditions, y=encoding, fill=groups)) + geom_boxplot() + 
  scale_fill_viridis(discrete = TRUE, alpha=0.6) +
  geom_jitter(color="black", size=0.4, alpha=0.9) +
  theme_ipsum() +
  theme(
    legend.position="none",
    plot.title = element_text(size=11)
  ) +
  ggtitle("Encoding") +
  xlab("") + 
  xlim(-100, 600)


  


