% load theta matricies 
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_cont.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_pat.mat') 
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\Rotation\rot_meanEloc_fm_c.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\Rotation\rot_meanEloc_fm_p.mat')

% 1. Encoding
%--------------------------------------------------------------------------

% extract the interested vectors from  the data
e_patients_m = meanEloc_fm_pat(:,1); % encoding-patients-MoBI
e_controls_m = meanEloc_fm_cont(:,1); % ecoding-controls-MoBI
e_patients_d = meanEloc_fm_pat(:,2); % encoding-patients-Desktop
e_controls_d = meanEloc_fm_cont(:,2); % encoding-controls-Desktop

% congregate them into one vector
encoding = [e_patients_m; e_controls_m; e_patients_d; e_controls_d]';

% assign the data to the groups
group = [repelem(1,10), repelem(2,15), repelem(3,10), repelem(4,15)];

% create the boxplot
graph1 = figure(1);
positions = [1 1.25 2 2.25];
boxplot(encoding,group, 'positions', positions);
ylabel('Theta Power')
title('Encoding')

set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4))])
set(gca,'xticklabel',{'MoBI','Desktop'})
ylim([-100,350]) % change y axis scale

% color the boxes
color = ['r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end
c = get(gca, 'Children');

hleg1 = legend(c(1:2), 'Patients', 'Controls');


% 2. Retrieval
%-------------------------------------------------------------------------

% extract the interested vectors from the data
r_patients_m = meanEloc_fm_pat(:,3); % retrieval-patients-MoBI
r_controls_m = meanEloc_fm_cont(:,3); % retrieval-controls-MoBI
r_patients_d = meanEloc_fm_pat(:,4); % retrieval-patients-Desktop
r_controls_d = meanEloc_fm_cont(:,4); % retrieval-controls-Desktop

% congregate them into one vector
retrieval = [r_patients_m; r_controls_m; r_patients_d; r_controls_d]';

% assign the data to the groups
group = [repelem(1,10), repelem(2,15), repelem(3,10), repelem(4,15)];

% create the boxplot
graph2 = figure(2);
positions = [1 1.25 2 2.25];
boxplot(retrieval,group, 'positions', positions);
ylabel('Theta Power')
title('Retrieval')

set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4))])
set(gca,'xticklabel',{'MoBI','Desktop'})
ylim([-100,350]) % change y axis scale

% color the boxes
color = ['r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end
c = get(gca, 'Children');

hleg1 = legend(c(1:2), 'Patients', 'Controls');


% 3. Rotation-MoBI
%--------------------------------------------------------------------------

% extract the interested vectors
rotation0_p_m = rot_meanEloc_fm_p(:,1); % rotation-0-patients-MoBI
rotation0_c_m = rot_meanEloc_fm_c(:,1); % rotation-0-controls-MoBI
rotation90_p_m = rot_meanEloc_fm_p(:,3); % rotation-90-patients-MoBI
rotation90_c_m = rot_meanEloc_fm_c(:,3); % rotation-90-controls-MoBI
rotation180_p_m = rot_meanEloc_fm_p(:,5); % rotation-180-patients-MoBI
rotation180_c_m = rot_meanEloc_fm_c(:,5); % rotation-180-controls-MoBI
rotation270_p_m = rot_meanEloc_fm_p(:,7); % rotation-270-patients-MoBI
rotation270_c_m = rot_meanEloc_fm_c(:,7); % rotation-270-controls-MoBI

% congregate them into one vector
rotation_m = [rotation0_p_m; rotation90_p_m; rotation180_p_m; rotation270_p_m;...
    rotation0_c_m; rotation90_c_m; rotation180_c_m; rotation270_c_m]';

% assign the data to the groups
group = [repelem(1,10), repelem(2,10), repelem(3,10), repelem(4,10),...
    repelem(5,15), repelem(6,15), repelem(7,15), repelem(8,15)];

% create the boxplot
graph3 = figure(3);
positions = [1 1.25 2 2.25 3 3.25 4 4.25];
boxplot(rotation_m,group, 'positions', positions);
ylabel('Theta Power')
title('Rotation-MoBI')

set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4)) mean(positions(5:6)) mean(positions(7:8))])
set(gca,'xticklabel',{'0','90','180','270'})
ylim([-100,350]) % change y axis scale

% color the boxes
color = ['r', 'b', 'r', 'b', 'r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end
c = get(gca, 'Children');

hleg1 = legend(c(1:2), 'Patients', 'Controls');



% 4. Rotation-Desktop
%--------------------------------------------------------------------------

% extract the interested vectors
rotation0_p_d = rot_meanEloc_fm_p(:,2); % rotation-0-patients-Desktop
rotation0_c_d = rot_meanEloc_fm_c(:,2); % rotation-0-controls-Desktop
rotation90_p_d = rot_meanEloc_fm_p(:,4); % rotation-90-patients-Desktop
rotation90_c_d = rot_meanEloc_fm_c(:,4); % rotation-90-controls-Desktop
rotation180_p_d = rot_meanEloc_fm_p(:,6); % rotation-180-patients-Desktop
rotation180_c_d = rot_meanEloc_fm_c(:,6); % rotation-180-controls-Desktop
rotation270_p_d = rot_meanEloc_fm_p(:,8); % rotation-270-patients-Desktop
rotation270_c_d = rot_meanEloc_fm_c(:,8); % rotation-270-controls-Desktop

% congregate them into one vector
rotation_d = [rotation0_p_d; rotation90_p_d; rotation180_p_d; rotation270_p_d;...
    rotation0_c_d; rotation90_c_d; rotation180_c_d; rotation270_c_d]';

% assign the data to the groups
group = [repelem(1,10), repelem(2,10), repelem(3,10), repelem(4,10),...
    repelem(5,15), repelem(6,15), repelem(7,15), repelem(8,15)];

% create the boxplot
graph4 = figure(4);
positions = [1 1.25 2 2.25 3 3.25 4 4.25];
boxplot(rotation_d,group, 'positions', positions);
ylabel('Theta Power')
title('Rotation-Desktop')

set(gca,'xtick',[mean(positions(1:2)) mean(positions(3:4)) mean(positions(5:6)) mean(positions(7:8))])
set(gca,'xticklabel',{'0','90','180','270'})
ylim([-100, 350]) % change y axis scale

% color the boxes
color = ['r', 'b', 'r', 'b', 'r', 'b', 'r', 'b'];
h = findobj(gca,'Tag','Box');
for j=1:length(h)
   patch(get(h(j),'XData'),get(h(j),'YData'),color(j),'FaceAlpha',.5);
end
c = get(gca, 'Children');

hleg1 = legend(c(1:2), 'Patients', 'Controls');

%

%--------------------------------------------------------------------------
% save the graphs

path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Graphs';

saveas(graph1,fullfile(path,'ThetaGraph1'),'png');
saveas(graph2,fullfile(path,'ThetaGraph2'),'png');
saveas(graph3,fullfile(path,'ThetaGraph3'),'png');
saveas(graph4,fullfile(path,'ThetaGraph4'),'png');



