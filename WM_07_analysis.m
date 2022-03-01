% 1. one sample t-test
%------------------------------------------------------------------

% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_pat.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_cont.mat')

% create a vector for encoding and retrieval theta powers separately 

encoding_vector  = [meanEloc_fm_pat(:,1); meanEloc_fm_pat(:,2); meanEloc_fm_cont(:,1); meanEloc_fm_cont(:,2)];
retrieval_vector = [meanEloc_fm_pat(:,3); meanEloc_fm_pat(:,4); meanEloc_fm_cont(:,3); meanEloc_fm_cont(:,4)];


% encoding - t-test
%------------------

[h1,p1,ci1,stats1] = ttest(encoding_vector)

[h2,p2,ci2,stats2] = ttest(retrieval_vector)




% 2. 2x2 ANOVA
%---------------------------------------------------------------------



% encoding ANOVA
%---------------

encoding_matrix = zeros(20,2);

% arrange the data
encoding_matrix(:,1) = [meanEloc_fm_pat(:,1); meanEloc_fm_cont(:,1)];
encoding_matrix(:,2) = [meanEloc_fm_pat(:,2); meanEloc_fm_cont(:,2)];

n_subjects = 10; % number of subjects in each group 

[p3,table3,stats3] = anova2(encoding_matrix,n_subjects)

c1 = multcompare(stats3)


% retrieval ANOVA
%---------------

retrieval_matrix = zeros(20,2);

% arrange the data
retrieval_matrix(:,1) = [meanEloc_fm_pat(:,3); meanEloc_fm_cont(:,3)];
retrieval_matrix(:,2) = [meanEloc_fm_pat(:,4); meanEloc_fm_cont(:,4)];

n_subjects = 10; % number of subjects in each group 

[p4,table4,stats4] = anova2(encoding_matrix,n_subjects)

c2 = multcompare(stats4)






