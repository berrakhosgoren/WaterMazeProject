%% 1. one sample t-test
%------------------------------------------------------------------

% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_pat.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_cont.mat')

% create a vector for encoding and retrieval theta powers separately 

encoding_all_vector     = [meanEloc_fm_pat(:,1); meanEloc_fm_pat(:,2); meanEloc_fm_cont(:,1); meanEloc_fm_cont(:,2)];
encoding_2_3_vector     = [meanEloc_fm_pat(:,3); meanEloc_fm_pat(:,4); meanEloc_fm_cont(:,3); meanEloc_fm_cont(:,4)];
retrieval_guess_vector  = [meanEloc_fm_pat(:,5); meanEloc_fm_pat(:,6); meanEloc_fm_cont(:,5); meanEloc_fm_cont(:,6)];
retrieval_search_vector = [meanEloc_fm_pat(:,7); meanEloc_fm_pat(:,8); meanEloc_fm_cont(:,7); meanEloc_fm_cont(:,8)];
retrieval_all_vector    = [meanEloc_fm_pat(:,9); meanEloc_fm_pat(:,10); meanEloc_fm_cont(:,9); meanEloc_fm_cont(:,10)];

% encoding - t-test
%------------------

[h1,p1,ci1,stats1] = ttest(encoding_all_vector);
[h2,p2,ci2,stats2] = ttest(encoding_2_3_vector);

[h3,p3,ci3,stats3] = ttest(retrieval_guess_vector);
[h4,p4,ci4,stats4] = ttest(retrieval_search_vector);
[h5,p5,ci5,stats5] = ttest(retrieval_all_vector);




%% 2. 2x2 ANOVA
%---------------------------------------------------------------------

% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_pat.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_cont.mat')

% Encoding (all) ANOVA

groups = [repelem(1,10), repelem(2,20)]';

en_all_mobi = [meanEloc_fm_pat(:,1); meanEloc_fm_cont(:,1)];
en_all_desk = [meanEloc_fm_pat(:,2); meanEloc_fm_cont(:,2)];

encoding_all_table = table(groups, en_all_mobi, en_all_desk, 'VariableNames', {'Group','MoBI','Desktop'});
setup = table([1 2]', 'VariableNames', {'Setup'});

rm1 = fitrm(encoding_all_table,'MoBI-Desktop~Group','WithinDesign',setup,'WithinModel','Setup');

ranovatbl1 = ranova(rm1, 'WithinModel','Setup');


% Encoding (2 & 3) ANOVA

en_2_3_mobi = [meanEloc_fm_pat(:,3); meanEloc_fm_cont(:,3)];
en_2_3_desk = [meanEloc_fm_pat(:,4); meanEloc_fm_cont(:,4)];

encoding_2_3_table = table(groups, en_2_3_mobi, en_2_3_desk, 'VariableNames', {'Group','MoBI','Desktop'});
setup = table([1 2]', 'VariableNames', {'Setup'});

rm2 = fitrm(encoding_2_3_table,'MoBI-Desktop~Group','WithinDesign',setup,'WithinModel','Setup');

ranovatbl2 = ranova(rm2, 'WithinModel','Setup');


% Retrieval (guess) ANOVA

ret_guess_mobi = [meanEloc_fm_pat(:,5); meanEloc_fm_cont(:,5)];
ret_guess_desk = [meanEloc_fm_pat(:,6); meanEloc_fm_cont(:,6)];

retrieval_guess_t = table(groups, ret_guess_mobi, ret_guess_desk, 'VariableNames', {'Group','MoBI','Desktop'});
setup = table([1 2]', 'VariableNames', {'Setup'});

rm3 = fitrm(retrieval_guess_t,'MoBI-Desktop~Group','WithinDesign',setup,'WithinModel','Setup');

ranovatbl3 = ranova(rm3, 'WithinModel','Setup');


% Retrieval (search) ANOVA

ret_search_mobi = [meanEloc_fm_pat(:,7); meanEloc_fm_cont(:,7)];
ret_search_desk = [meanEloc_fm_pat(:,8); meanEloc_fm_cont(:,8)];

retrieval_search_t = table(groups, ret_search_mobi, ret_search_desk, 'VariableNames', {'Group','MoBI','Desktop'});
setup = table([1 2]', 'VariableNames', {'Setup'});

rm4 = fitrm(retrieval_search_t,'MoBI-Desktop~Group','WithinDesign',setup,'WithinModel','Setup');

ranovatbl4 = ranova(rm4, 'WithinModel','Setup');


% Retrieval (all) ANOVA

ret_all_mobi = [meanEloc_fm_pat(:,9); meanEloc_fm_cont(:,9)];
ret_all_desk = [meanEloc_fm_pat(:,10); meanEloc_fm_cont(:,10)];

retrieval_all_t = table(groups, ret_all_mobi, ret_all_desk, 'VariableNames', {'Group','MoBI','Desktop'});
setup = table([1 2]', 'VariableNames', {'Setup'});

rm5 = fitrm(retrieval_all_t,'MoBI-Desktop~Group','WithinDesign',setup,'WithinModel','Setup');

ranovatbl5 = ranova(rm5, 'WithinModel','Setup');


%% 3. Rotation ANOVA
%---------------------------------------------------------------

% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\Rotation\rot_meanEloc_fm_p.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\Rotation\rot_meanEloc_fm_c.mat')


% 2 X 2 X 4 
%----------------

% arrange the data
rot_mobi_0   = [rot_meanEloc_fm_p(:,1); rot_meanEloc_fm_c(:,1)];
rot_desk_0   = [rot_meanEloc_fm_p(:,3); rot_meanEloc_fm_c(:,3)];
rot_mobi_90  = [rot_meanEloc_fm_p(:,5); rot_meanEloc_fm_c(:,5)];
rot_desk_90  = [rot_meanEloc_fm_p(:,7); rot_meanEloc_fm_c(:,7)];
rot_mobi_180 = [rot_meanEloc_fm_p(:,2); rot_meanEloc_fm_c(:,2)];
rot_desk_180 = [rot_meanEloc_fm_p(:,4); rot_meanEloc_fm_c(:,4)];
rot_mobi_270 = [rot_meanEloc_fm_p(:,6); rot_meanEloc_fm_c(:,6)];
rot_desk_270 = [rot_meanEloc_fm_p(:,8); rot_meanEloc_fm_c(:,8)];

groups = [repelem(1,10), repelem(2,20)]';

rotation1_table = table(groups, rot_mobi_0, rot_desk_0, rot_mobi_90, rot_desk_90,...
    rot_mobi_180, rot_desk_180,rot_mobi_270, rot_desk_270,...
    'VariableNames', {'Group','Mobi0','Desk0','Mobi90','Desk90','Mobi180','Desk180','Mobi270','Desk270'});

withinDesign = table([1 1 1 1 2 2 2 2]',[1:4 1:4]','VariableNames',{'Setup','Rotation'});

withinDesign.Setup     = categorical(withinDesign.Setup);
withinDesign.Rotation  = categorical(withinDesign.Rotation);

rm6 = fitrm(rotation1_table,'Mobi0-Desk270 ~ Group','WithinDesign',withinDesign);

ranovatbl6 = ranova(rm6,'WithinModel','Setup*Rotation');



% 2 X 2 X 2 
%----------------


unrotated_mobi = [rot_meanEloc_fm_p(:,1); rot_meanEloc_fm_c(:,1)];
unrotated_desk  = [rot_meanEloc_fm_p(:,3); rot_meanEloc_fm_c(:,3)];

% take the average of rotated trials 

rotated_mobi_all = [rot_mobi_90, rot_mobi_180, rot_mobi_270];
rotated_desk_all = [rot_desk_90, rot_desk_180, rot_desk_270];

rotated_mobi = mean(rotated_mobi_all,2);
rotated_desk = mean(rotated_desk_all,2);


groups = [repelem(1,10), repelem(2,20)]';

rotation2_table = table(groups, rotated_mobi, unrotated_mobi, rotated_desk, unrotated_desk,...
    'VariableNames', {'Group','RotatedMobi','UnrotatedMobi','RotatedDesk','UnrotatedDesk'});

withinDesign = table([1 1 2 2]',[1 2 1 2]','VariableNames',{'Setup','Rotation'});

withinDesign.Setup     = categorical(withinDesign.Setup);
withinDesign.Rotation  = categorical(withinDesign.Rotation);

rm7 = fitrm(rotation2_table,'RotatedMobi-UnrotatedDesk ~ Group','WithinDesign',withinDesign);

ranovatbl7 = ranova(rm7,'WithinModel','Setup*Rotation');


