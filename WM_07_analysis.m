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

% Encoding ANOVA

encoding_datamat = zeros(25,2);

% arrange the data
encoding_datamat(:,1) = [meanEloc_fm_pat(:,1); meanEloc_fm_cont(:,1)];
encoding_datamat(:,2) = [meanEloc_fm_pat(:,2); meanEloc_fm_cont(:,2)];

encoding_between = [repelem(1,10), repelem(2,15)]';

[tbl1,rm1] = simple_mixed_anova(encoding_datamat, encoding_between, {'Condition'},{'Group'});


% Retrieval ANOVA

retrieval_datamat = zeros(25,2);

% arrange the data
retrieval_datamat(:,1) = [meanEloc_fm_pat(:,3); meanEloc_fm_cont(:,3)];
retrieval_datamat(:,2) = [meanEloc_fm_pat(:,4); meanEloc_fm_cont(:,4)];

retrieval_between = [repelem(1,10), repelem(2,15)]';

[tbl2,rm2] = simple_mixed_anova(retrieval_datamat, retrieval_between, {'Condition'},{'Group'});


% 

% 3. 2x2x4 ANOVA
%---------------------------------------------------------------

% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\Rotation\rot_meanEloc_fm_p.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\Rotation\rot_meanEloc_fm_c.mat')


rotation_datamat = zeros(25,2,4);

% arrange the data
rotation_datamat(:,1,1) = [rot_meanEloc_fm_p(:,1); rot_meanEloc_fm_c(:,1)];
rotation_datamat(:,2,1) = [rot_meanEloc_fm_p(:,2); rot_meanEloc_fm_c(:,2)];
rotation_datamat(:,1,2) = [rot_meanEloc_fm_p(:,3); rot_meanEloc_fm_c(:,3)];
rotation_datamat(:,2,2) = [rot_meanEloc_fm_p(:,4); rot_meanEloc_fm_c(:,4)];
rotation_datamat(:,1,3) = [rot_meanEloc_fm_p(:,5); rot_meanEloc_fm_c(:,5)];
rotation_datamat(:,2,3) = [rot_meanEloc_fm_p(:,6); rot_meanEloc_fm_c(:,6)];
rotation_datamat(:,1,4) = [rot_meanEloc_fm_p(:,7); rot_meanEloc_fm_c(:,7)];
rotation_datamat(:,2,4) = [rot_meanEloc_fm_p(:,8); rot_meanEloc_fm_c(:,8)];

rotation_between = [repelem(1,10), repelem(2,15)]';

[tbl3,rm3] = simple_mixed_anova(rotation_datamat, rotation_between, {'Condition','Rotation'},{'Group'});




