
# Graphs
#----------------------------------------------------------------

# working directory

setwd("C:/Users/BERRAK/Documents/GitHub/WaterMazeProject")


# First load the data

library(R.matlab)

meanEloc_fm_cont  = readMat("C:/Users/BERRAK/Documents/GitHub/WaterMazeProject/Results/Tables/AverageOverEloc/meanEloc_fm_cont.mat");
meanEloc_fm_pat   = readMat("C:/Users/BERRAK/Documents/GitHub/WaterMazeProject/Results/Tables/AverageOverEloc/meanEloc_fm_pat.mat");
rot_meanEloc_fm_c = readMat("C:/Users/BERRAK/Documents/GitHub/WaterMazeProject/Results/Tables/AverageOverEloc/Rotation/rot_meanEloc_fm_c.mat");
rot_meanEloc_fm_p = readMat("C:/Users/BERRAK/Documents/GitHub/WaterMazeProject/Results/Tables/AverageOverEloc/Rotation/rot_meanEloc_fm_p.mat");


# convert it to matrix 

meanEloc_fm_cont  = matrix(unlist(meanEloc_fm_cont), ncol = 10, byrow = FALSE)
meanEloc_fm_pat   = matrix(unlist(meanEloc_fm_pat), ncol = 10, byrow = FALSE)
rot_meanEloc_fm_c = matrix(unlist(rot_meanEloc_fm_c), ncol = 8, byrow = FALSE)
rot_meanEloc_fm_p = matrix(unlist(rot_meanEloc_fm_p), ncol = 8, byrow = FALSE)




# 1. Encoding - All
#-------------------------

# extract the interested vectors from  the data
e_all_patients_m = meanEloc_fm_pat[,1]; # encoding-all-patients-MoBI
e_all_controls_m = meanEloc_fm_cont[,1]; # encoding-all-controls-MoBI
e_all_patients_d = meanEloc_fm_pat[,2]; # encoding-all-patients-Desktop
e_all_controls_d = meanEloc_fm_cont[,2]; # encoding-all-controls-Desktop

# congregate them into one vector
encoding_all = c(e_all_patients_m, e_all_controls_m, e_all_patients_d, e_all_controls_d)


# library
library(ggplot2)
library(tidyverse)
library(hrbrthemes)
library(viridis)
library(ggforce)
library(ggdist)
library(gghalves)

# create a data frame
conditions     = rep(c("MoBI", "Desktop"), each=30);
groups         = c(rep("Patients",10), rep("Controls",20));
data_enc_all   = data.frame(conditions, groups, encoding_all);


g1 <- 
  ggplot(data_enc_all, aes(x=conditions, y=encoding_all, fill=groups)) + 
  geom_violin(fill = "grey90") + 
  scale_y_continuous(limits = c(-100,150),breaks=seq(-100,150,50)) +
  geom_boxplot(width = .2, outlier.shape = NA, coef = 0) +
  ggtitle("Encoding (All)") +
  ylab("Theta Power") +
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"), axis.title = element_text(size = 16), axis.text = element_text(size = 12))

g1 + geom_point(alpha = .7, position = position_jitter(seed = 1))
g1 + ggforce::geom_sina(method = "counts", alpha = .3)
g1 + ggbeeswarm::geom_quasirandom(width = .3, alpha = .5, varwidth = TRUE, size = 2)


# 2. Encoding - 2&3
#-------------------------

# extract the interested vectors from  the data
e_2_3_patients_m = meanEloc_fm_pat[,3]; # encoding-2&3-patients-MoBI
e_2_3_controls_m = meanEloc_fm_cont[,3]; # encoding-2&3-controls-MoBI
e_2_3_patients_d = meanEloc_fm_pat[,4]; # encoding-2&3-patients-Desktop
e_2_3_controls_d = meanEloc_fm_cont[,4]; # encoding-2&3-controls-Desktop

# congregate them into one vector
encoding_2_3 = c(e_2_3_patients_m, e_2_3_controls_m, e_2_3_patients_d, e_2_3_controls_d)


# create a data frame
conditions     = rep(c("MoBI", "Desktop"), each=30);
groups         = c(rep("Patients",10), rep("Controls",20));
data_enc_2_3   = data.frame(conditions, groups, encoding_2_3);


g2 <- 
  ggplot(data_enc_2_3, aes(x=conditions, y=encoding_2_3, fill=groups)) + 
  geom_violin(fill = "grey90") + 
  scale_y_continuous(limits = c(-100,150),breaks=seq(-100,150,50)) +
  geom_boxplot(width = .2, outlier.shape = NA, coef = 0) +
  ggtitle("Encoding (2 & 3)") +
  ylab("Theta Power") +
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"), axis.title = element_text(size = 16), axis.text = element_text(size = 12))

g2 + geom_point(alpha = .7, position = position_jitter(seed = 1))
g2 + ggforce::geom_sina(method = "counts", alpha = .5)
g2 + ggbeeswarm::geom_quasirandom(width = .3, alpha = .5, varwidth = TRUE, size = 2)


# 3. Retrieval (Guess)
#-------------------------

# extract the interested vectors from  the data
r_guess_patients_m = meanEloc_fm_pat[,5]; # patients-MoBI
r_guess_controls_m = meanEloc_fm_cont[,5]; # controls-MoBI
r_guess_patients_d = meanEloc_fm_pat[,6]; # patients-Desktop
r_guess_controls_d = meanEloc_fm_cont[,6]; # controls-Desktop

# congregate them into one vector
retrieval_guess = c(r_guess_patients_m, r_guess_controls_m, r_guess_patients_d, r_guess_controls_d)

# create a data frame
conditions       = rep(c("MoBI", "Desktop"), each=30);
groups           = c(rep("Patients",10), rep("Controls",20));
data_ret_guess   = data.frame(conditions, groups, retrieval_guess);


g3 <- 
  ggplot(data_ret_guess, aes(x=conditions, y=retrieval_guess, fill=groups)) + 
  geom_violin(fill = "grey90") + 
  scale_y_continuous(limits = c(-100,150),breaks=seq(-100,150,50)) +
  geom_boxplot(width = .2, outlier.shape = NA, coef = 0) +
  ggtitle("Retrieval (Guess)") +
  ylab("Theta Power") + 
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"), axis.title = element_text(size = 16), axis.text = element_text(size = 12))

g3 + geom_point(alpha = .7, position = position_jitter(seed = 1))
g3 + ggforce::geom_sina(method = "counts", alpha = .5)
g3 + ggbeeswarm::geom_quasirandom(width = .3, alpha = .5, varwidth = TRUE, size = 2)



# 4. Retrieval (Search)
#-------------------------

# extract the interested vectors from  the data
r_search_patients_m = meanEloc_fm_pat[,7]; # patients-MoBI
r_search_controls_m = meanEloc_fm_cont[,7]; # controls-MoBI
r_search_patients_d = meanEloc_fm_pat[,8]; # patients-Desktop
r_search_controls_d = meanEloc_fm_cont[,8]; # controls-Desktop

# congregate them into one vector
retrieval_search = c(r_search_patients_m, r_search_controls_m, r_search_patients_d, r_search_controls_d)

# create a data frame
conditions       = rep(c("MoBI", "Desktop"), each=30);
groups           = c(rep("Patients",10), rep("Controls",20));
data_ret_search   = data.frame(conditions, groups, retrieval_search);


g4 <- 
  ggplot(data_ret_search, aes(x=conditions, y=retrieval_search, fill=groups)) + 
  geom_violin(fill = "grey90") + 
  scale_y_continuous(limits = c(-100,150),breaks=seq(-100,150,50)) +
  geom_boxplot(width = .2, outlier.shape = NA, coef = 0) +
  ggtitle("Retrieval (Search)") +
  ylab("Theta Power") + 
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"), axis.title = element_text(size = 16), axis.text = element_text(size = 12))

g4 + geom_point(alpha = .7, position = position_jitter(seed = 1))
g4 + ggforce::geom_sina(method = "counts", alpha = .5)
g4 + ggbeeswarm::geom_quasirandom(width = .3, alpha = .5, varwidth = TRUE, size = 2)



# 5. Retrieval (All)
#-------------------------

# extract the interested vectors from  the data
r_all_patients_m = meanEloc_fm_pat[,9]; # patients-MoBI
r_all_controls_m = meanEloc_fm_cont[,9]; # controls-MoBI
r_all_patients_d = meanEloc_fm_pat[,10]; # patients-Desktop
r_all_controls_d = meanEloc_fm_cont[,10]; # controls-Desktop

# congregate them into one vector
retrieval_all = c(r_all_patients_m, r_all_controls_m, r_all_patients_d, r_all_controls_d)

# create a data frame
conditions     = rep(c("MoBI", "Desktop"), each=30);
groups         = c(rep("Patients",10), rep("Controls",20));
data_ret_all   = data.frame(conditions, groups, retrieval_all);


g5 <- 
  ggplot(data_ret_all, aes(x=conditions, y=retrieval_all, fill=groups)) + 
  geom_violin(fill = "grey90") + 
  scale_y_continuous(limits = c(-100,150),breaks=seq(-100,150,50)) +
  geom_boxplot(width = .2, outlier.shape = NA, coef = 0) +
  ggtitle("Retrieval (All)") +
  ylab("Theta Power") + 
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"), axis.title = element_text(size = 16), axis.text = element_text(size = 12))

g5 + geom_point(alpha = .7, position = position_jitter(seed = 1))
g5 + ggforce::geom_sina(method = "counts", alpha = .5)
g5 + ggbeeswarm::geom_quasirandom(width = .3, alpha = .5, varwidth = TRUE, size = 2)



# 6. Rotation MoBI
#-------------------------

# extract the interested vectors from  the data
m_0_p   = rot_meanEloc_fm_p[,1]; 
m_0_c   = rot_meanEloc_fm_c[,1]; 
m_90_p  = rot_meanEloc_fm_p[,3]; 
m_90_c  = rot_meanEloc_fm_c[,3]; 
m_180_p = rot_meanEloc_fm_p[,5]; 
m_180_c = rot_meanEloc_fm_c[,5];  
m_270_p = rot_meanEloc_fm_p[,7]; 
m_270_c = rot_meanEloc_fm_c[,7]; 

# congregate them into one vector
rot_mobi = c(m_0_p, m_0_c, m_90_p, m_90_c, m_180_p, m_180_c, m_270_p, m_270_c);

# create a data frame
rot_conditions_m = rep(c("0", "90", "180", "270"), each=30);
rot_groups_m     = c(rep("Patients",10), rep("Controls",20));
data_rot_m   = data.frame(rot_conditions_m, rot_groups_m, rot_mobi);

g6 <- 
  ggplot(data_rot_m, aes(x=rot_conditions_m, y=rot_mobi, fill=rot_groups_m)) + 
  geom_violin(fill = "grey90") + 
  scale_y_continuous(limits = c(-100,150),breaks=seq(-100,150,50)) +
  geom_boxplot(width = .2, outlier.shape = NA, coef = 0) +
  ggtitle("Rotation MoBI") +
  ylab("Theta Power") + xlab("Conditions") +
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"), axis.title = element_text(size = 16), axis.text = element_text(size = 12))

g6 + geom_point(alpha = .7, position = position_jitter(seed = 1))
g6 + ggforce::geom_sina(method = "counts", alpha = .5)
g6 + ggbeeswarm::geom_quasirandom(width = .3, alpha = .5, varwidth = TRUE, size = 2)



# 7. Rotation Desktop
#-------------------------

# extract the interested vectors from  the data
d_0_p   = rot_meanEloc_fm_p[,2]; 
d_0_c   = rot_meanEloc_fm_c[,2]; 
d_90_p  = rot_meanEloc_fm_p[,4]; 
d_90_c  = rot_meanEloc_fm_c[,4]; 
d_180_p = rot_meanEloc_fm_p[,6]; 
d_180_c = rot_meanEloc_fm_c[,6];  
d_270_p = rot_meanEloc_fm_p[,8]; 
d_270_c = rot_meanEloc_fm_c[,8]; 

# congregate them into one vector
rot_desk = c(d_0_p, d_0_c, d_90_p, d_90_c, d_180_p, d_180_c, d_270_p, d_270_c);

# create a data frame
rot_conditions_d = rep(c("0", "90", "180", "270"), each=30);
rot_groups_d     = c(rep("Patients",10), rep("Controls",20));
data_rot_d   = data.frame(rot_conditions_d, rot_groups_d, rot_desk);

g7 <- 
  ggplot(data_rot_d, aes(x=rot_conditions_d, y=rot_desk, fill=rot_groups_d)) + 
  geom_violin(fill = "grey90") + 
  scale_y_continuous(limits = c(-100,150),breaks=seq(-100,150,50)) +
  geom_boxplot(width = .2, outlier.shape = NA, coef = 0) +
  ggtitle("Rotation Desktop") +
  ylab("Theta Power") + xlab("Conditions") +
  theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"), axis.title = element_text(size = 16), axis.text = element_text(size = 12))

g7 + geom_point(alpha = .7, position = position_jitter(seed = 1))
g7 + ggforce::geom_sina(method = "counts", alpha = .5)
g7 + ggbeeswarm::geom_quasirandom(width = .3, alpha = .5, varwidth = TRUE, size = 2)


  


