% 1. Search Duration - Frontal Midline Theta (Encoding) Regression
%------------------------------------------------------------------------

% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\Behavioral\searchduration_patients.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\Behavioral\searchduration_controls.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\p_erd_encoding_2_3.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\c_erd_encoding_2_3.mat')


% seperate them as mobi and desktop

duration_p_m = searchduration_patients(1:12,:);
duration_p_d = searchduration_patients(13:24,:);

duration_c_m = searchduration_controls(1:12,:);
duration_c_d = searchduration_controls(13:24,:);


% take the mean value of each participant

meanDuration_p_m = mean(duration_p_m, 1);
meanDuration_p_d = mean(duration_p_d, 1);

meanDuration_c_m = mean(duration_c_m, 1);
meanDuration_c_d = mean(duration_c_d, 1);



% generate regression graph for all participants
%-----------------------------------------------


% generate the plots 

f1 = figure(1);
set(gcf, 'Position', get(0, 'Screensize'));

% 1. Patient-MoBI

subplot(2,2,1)
regression1 = table(p_erd_encoding_2_3(:,1), meanDuration_p_m');
mdl1 = fitlm(regression1,'RobustOpts','on');
plot(mdl1)
xlabel('Encoding - Theta Power')
ylabel('Search Duration')
title('Patients-MoBI','fontweight','bold','fontsize',18)


% 2. Patient-Desktop

subplot(2,2,2)
regression2 = table(p_erd_encoding_2_3(:,2), meanDuration_p_d');
mdl2 = fitlm(regression2,'RobustOpts','on');
plot(mdl2)
xlabel('Encoding - Theta Power')
ylabel('Search Duration')
title('Patients-Desktop','fontweight','bold','fontsize',18)


% 3. Control-MoBI

subplot(2,2,3)
regression3 = table(c_erd_encoding_2_3(:,1), meanDuration_c_m');
mdl3 = fitlm(regression3,'RobustOpts','on');
plot(mdl3)
xlabel('Encoding - Theta Power')
ylabel('Search Duration')
title('Controls-MoBI','fontweight','bold','fontsize',18)


% 4. Control-Desktop

subplot(2,2,4)
regression4 = table(c_erd_encoding_2_3(:,2), meanDuration_c_d');
mdl4 = fitlm(regression4,'RobustOpts','on');
plot(mdl4)
xlabel('Encoding - Theta Power')
ylabel('Search Duration')
title('Controls-Desktop','fontweight','bold','fontsize',18)


% save the figures
%----------------------------

path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Graphs';

saveas(f1,fullfile(path,'Regression1'),'png');



% 2. Distance Error - Frontal Midline Theta (Encoding) Regression
%-------------------------------------------------------------------------------

% load the data

load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_pat.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\meanEloc_fm_cont.mat') 
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\Behavioral\distance_error_patients.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\Behavioral\distance_error_controls.mat')


% seperate them as mobi and desktop

theta_p_m = meanEloc_fm_pat(:,1);
theta_p_d = meanEloc_fm_pat(:,2);

theta_c_m = meanEloc_fm_cont(:,1);
theta_c_d = meanEloc_fm_cont(:,2);

distance_error_p_m = distance_error_patients(1:24,:);
distance_error_p_d = distance_error_patients(25:48,:);

distance_error_c_m = distance_error_controls(1:24,:);
distance_error_c_d = distance_error_controls(25:48,:);


% take the mean value of each participant

meanDistance_error_p_m = mean(distance_error_p_m, 1);
meanDistance_error_p_d = mean(distance_error_p_d, 1);

meanDistance_error_c_m = mean(distance_error_c_m, 1);
meanDistance_error_c_d = mean(distance_error_c_d, 1);


% generate regression graph for all participants
%-----------------------------------------------

% generate the plots 

f2 = figure(2);
set(gcf, 'Position', get(0, 'Screensize'));

% 1. Patient-MoBI

subplot(2,2,1)
regression5 = table(theta_p_m, meanDistance_error_p_m');
mdl5 = fitlm(regression5,'RobustOpts','on');
plot(mdl5)
xlabel('Encoding - Theta Power')
ylabel('Distance Error')
title('Patients-MoBI','fontweight','bold','fontsize',18)


% 2. Patient-Desktop

subplot(2,2,2)
regression6 = table(theta_p_d, meanDistance_error_p_d');
mdl6 = fitlm(regression6,'RobustOpts','on');
plot(mdl6)
xlabel('Encoding - Theta Power')
ylabel('Distance Error')
title('Patients-Desktop','fontweight','bold','fontsize',18)


% 3. Control-MoBI

subplot(2,2,3)
regression7 = table(theta_c_m, meanDistance_error_c_m');
mdl7 = fitlm(regression7,'RobustOpts','on');
plot(mdl7)
xlabel('Encoding - Theta Power')
ylabel('Distance Error')
title('Controls-MoBI','fontweight','bold','fontsize',18)


% 4. Control-Desktop

subplot(2,2,4)
regression8 = table(theta_c_d, meanDistance_error_c_d');
mdl8 = fitlm(regression8,'RobustOpts','on');
plot(mdl8)
xlabel('Encoding - Theta Power')
ylabel('Distance Error')
title('Controls-Desktop','fontweight','bold','fontsize',18)


% save the figures
%----------------------------

path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Graphs';

saveas(f2,fullfile(path,'Regression2'),'png');




% 3. Distance Error - Frontal Midline Theta (Retrieval) Regression
%---------------------------------------------------------


% seperate them as mobi and desktop
theta2_p_m = meanEloc_fm_pat(:,3);
theta2_p_d = meanEloc_fm_pat(:,4);

theta2_c_m = meanEloc_fm_cont(:,3);
theta2_c_d = meanEloc_fm_cont(:,4);



% generate regression graph for all participants
%-----------------------------------------------

% take the mean value of each participant

meanDistance_error_p_m = mean(distance_error_p_m, 1);
meanDistance_error_p_d = mean(distance_error_p_d, 1);

meanDistance_error_c_m = mean(distance_error_c_m, 1);
meanDistance_error_c_d = mean(distance_error_c_d, 1);


% generate the plots 

f3 = figure(3);
set(gcf, 'Position', get(0, 'Screensize'));

% 1. Patient-MoBI

subplot(2,2,1)
regression9 = table(theta2_p_m, meanDistance_error_p_m');
mdl9 = fitlm(regression9,'RobustOpts','on');
plot(mdl9)
xlabel('Retrieval - Theta Power')
ylabel('Distance Error')
title('Patients-MoBI','fontweight','bold','fontsize',18)


% 2. Patient-Desktop

subplot(2,2,2)
regression10 = table(theta2_p_d, meanDistance_error_p_d');
mdl10 = fitlm(regression10,'RobustOpts','on');
plot(mdl10)
xlabel('Retrieval - Theta Power')
ylabel('Distance Error')
title('Patients-Desktop','fontweight','bold','fontsize',18)


% 3. Control-MoBI

subplot(2,2,3)
regression11 = table(theta2_c_m, meanDistance_error_c_m');
mdl11 = fitlm(regression11,'RobustOpts','on');
plot(mdl11)
xlabel('Retrieval - Theta Power')
ylabel('Distance Error')
title('Controls-MoBI','fontweight','bold','fontsize',18)


% 4. Control-Desktop

subplot(2,2,4)
regression12 = table(theta2_c_d, meanDistance_error_c_d');
mdl12 = fitlm(regression12,'RobustOpts','on');
plot(mdl12)
xlabel('Retrieval - Theta Power')
ylabel('Distance Error')
title('Controls-Desktop','fontweight','bold','fontsize',18)


% save the figure
%----------------------------

saveas(f3,fullfile(path,'Regression3'),'png');



% 4. Generate regression graphs per person (Search - Encoding) 
%-----------------------------------------------------------------

% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\p_var_epoch_en.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\c_var_epoch_en.mat')



patients = [81001:81004,81006:81010];
controls = [82001:82004,82006:82008,84009,83001:83003,83006:83010];

% iterate over patients
for pi = 1:9

    % 1. Patient-MoBI

    regression13 = table(p_var_epoch_en(:,1,pi), duration_p_m(:,pi));
    mdl13 = fitlm(regression13,'RobustOpts','on');
    
    f4 = figure(4);
    set(gcf,'Name','Patients-MoBI')
    set(gcf, 'Position', get(0, 'Screensize'));

    subplot(3,4,pi)
    plot(mdl13)
    xlabel('Encoding - Theta Power')
    ylabel('Search Duration')
    title(num2str(patients(pi)))
    
    sgtitle('Patients-MoBI','fontweight','bold','fontsize',18)
    
    
    
    % 2. Patient-Desktop

    regression14 = table(p_var_epoch_en(:,2,pi), duration_p_d(:,pi));
    mdl14 = fitlm(regression14,'RobustOpts','on');
    
    f5 = figure(5);
    set(gcf,'Name','Patients-Desktop')
    set(gcf, 'Position', get(0, 'Screensize'));
    
    subplot(3,4,pi)
    plot(mdl14)
    xlabel('Encoding - Theta Power')
    ylabel('Search Duration')
    title(num2str(patients(pi)))
    
    sgtitle('Patients-Desktop','fontweight','bold','fontsize',18)
    
end


% iterate over controls
for ci = 1:16


    % 3. Control-MoBI

    regression15 = table(c_var_epoch_en(:,1,ci), duration_c_m(:,ci));
    mdl15 = fitlm(regression15,'RobustOpts','on');
    
    f6 = figure(6);
    set(gcf,'Name','Controls-MoBI')
    set(gcf, 'Position', get(0, 'Screensize'));
    
    subplot(4,5,ci)
    plot(mdl15)
    xlabel('Encoding - Theta Power')
    ylabel('Search Duration')
    title(num2str(controls(ci)))
    
    sgtitle('Controls-MoBI','fontweight','bold','fontsize',18)


    % 4. Control-Desktop

    regression16 = table(c_var_epoch_en(:,2,ci), duration_c_d(:,ci));
    mdl16 = fitlm(regression16,'RobustOpts','on');
    
    f7 = figure(7);
    set(gcf,'Name','Controls-Desktop')
    set(gcf, 'Position', get(0, 'Screensize'));
    
    subplot(4,5,ci)
    plot(mdl16)
    xlabel('Encoding - Theta Power')
    ylabel('Search Duration')
    title(num2str(controls(ci)))
    
    sgtitle('Controls-Desktop','fontweight','bold','fontsize',18)

end


% save the figures
%----------------------------

saveas(f4,fullfile(path,'Regression4'),'png');
saveas(f5,fullfile(path,'Regression5'),'png');
saveas(f6,fullfile(path,'Regression6'),'png');
saveas(f7,fullfile(path,'Regression7'),'png');


% 5. Generate regression graphs per person (Distance - Retrieval)
%---------------------------------------------------------------------


% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\p_var_epoch_re.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\c_var_epoch_re.mat')


% iterate over patients
for pi = 1:9

    % 1. Patient-MoBI

    regression17 = table(p_var_epoch_re(:,1,pi), distance_error_p_m(:,pi));
    mdl17 = fitlm(regression17,'RobustOpts','on');
    
    f8 = figure(8);
    set(gcf,'Name','Patients-MoBI')
    set(gcf, 'Position', get(0, 'Screensize'));

    subplot(3,4,pi)
    plot(mdl17)
    xlabel('Retrieval - Theta Power')
    ylabel('Distance Error')
    title(num2str(patients(pi)))
    
    sgtitle('Patients-MoBI','fontweight','bold','fontsize',18)
    
    
    
    % 2. Patient-Desktop

    regression18 = table(p_var_epoch_re(:,2,pi), distance_error_p_d(:,pi));
    mdl18 = fitlm(regression18,'RobustOpts','on');
    
    f9 = figure(9);
    set(gcf,'Name','Patients-Desktop')
    set(gcf, 'Position', get(0, 'Screensize'));
    
    subplot(3,4,pi)
    plot(mdl18)
    xlabel('Retrieval - Theta Power')
    ylabel('Distance Error')
    title(num2str(patients(pi)))
    
    sgtitle('Patients-Desktop','fontweight','bold','fontsize',18)
    
end


% iterate over controls
for ci = 1:16


    % 3. Control-MoBI

    regression19 = table(c_var_epoch_re(:,1,ci), distance_error_c_m(:,ci));
    mdl19 = fitlm(regression19,'RobustOpts','on');
    
    f10 = figure(10);
    set(gcf,'Name','Controls-MoBI')
    set(gcf, 'Position', get(0, 'Screensize'));
    
    subplot(4,5,ci)
    plot(mdl19)
    xlabel('Retrieval - Theta Power')
    ylabel('Distance Error')
    title(num2str(controls(ci)))
    
    sgtitle('Controls-MoBI','fontweight','bold','fontsize',18)


    % 4. Control-Desktop

    regression20 = table(c_var_epoch_re(:,2,ci), distance_error_c_d(:,ci));
    mdl20 = fitlm(regression20,'RobustOpts','on');
    
    f11 = figure(11);
    set(gcf,'Name','Controls-Desktop')
    set(gcf, 'Position', get(0, 'Screensize'));
    
    subplot(4,5,ci)
    plot(mdl20)
    xlabel('Retrieval - Theta Power')
    ylabel('Distance Error')
    title(num2str(controls(ci)))
    
    sgtitle('Controls-Desktop','fontweight','bold','fontsize',18)

end


% save the figures
%----------------------------

saveas(f8,fullfile(path,'Regression8'),'png');
saveas(f9,fullfile(path,'Regression9'),'png');
saveas(f10,fullfile(path,'Regression10'),'png');
saveas(f11,fullfile(path,'Regression11'),'png');

%

%% 6. Plot the Target and Response Positions
%---------------------------------------------

% load the data
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\Behavioral\positions_patients.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\Behavioral\positions_controls.mat')

% seperate them as mobi and desktop
positions_patients_m = positions_patients(1:24,:,:);
positions_patients_d = positions_patients(25:48,:,:);
positions_controls_m = positions_controls(1:24,:,:);
positions_controls_d = positions_controls(25:48,:,:);


patients = [81001:81004,81006:81011];
controls = [82001:82004,82006:82008,84009,82011,83001:83003,83006:83011];

path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Graphs';


% iterate over patients
for pi = 1:9
    
    if rem(pi,2) == 1
        
       h = figure;
       set(gcf, 'Position', get(0, 'Screensize'));
       
        a = 1;
        % iterate over blocks
        for bi = 1:6

    
            % 1. Patient-MoBI
    
            % plot the arena
            subplot(4,6,bi)
            p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 3.8);
            plot(p, 'FaceColor', 'r')
            axis equal
    
            % plot the target position
            hold on
            plot(positions_patients_m(a,1,pi),positions_patients_m(a,2,pi),'p','MarkerFaceColor','b')
    
            % plot the response positions
            hold on
            plot(positions_patients_m(a:(a+3),3,pi),positions_patients_m(a:(a+3),4,pi),'p','MarkerFaceColor','c')
        
    
            title([num2str(patients(pi)),'-MoBI ', num2str(bi) '. Block' ])
    
    
            % 2. Patient-Desktop
    
            % plot the arena
            subplot(4,6,(bi+6))
            p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 3.8);
            plot(p, 'FaceColor', 'r')
            axis equal
    
            % plot the target position
            hold on
            plot(positions_patients_d(a,1,pi),positions_patients_d(a,2,pi),'p','MarkerFaceColor','b')
    
            % plot the response positions
            hold on
            plot(positions_patients_d(a:(a+3),3,pi),positions_patients_d(a:(a+3),4,pi),'p','MarkerFaceColor','c')
    
            a = a + 4;
    
            title([num2str(patients(pi)),'-Desktop ', num2str(bi) '. Block' ])        

        end     
        
        
    else
        
        a = 1;
        % iterate over blocks
        for bi = 1:6

    
            % 1. Patient-MoBI
    
            % plot the arena
            subplot(4,6,(bi+12))
            p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 3.8);
            plot(p, 'FaceColor', 'r')
            axis equal
    
            % plot the target position
            hold on
            plot(positions_patients_m(a,1,pi),positions_patients_m(a,2,pi),'p','MarkerFaceColor','b')
    
            % plot the response positions
            hold on
            plot(positions_patients_m(a:(a+3),3,pi),positions_patients_m(a:(a+3),4,pi),'p','MarkerFaceColor','c')
        
    
            title([num2str(patients(pi)),'-MoBI ', num2str(bi) '. Block' ])
    
    
            % 2. Patient-Desktop
    
            % plot the arena
            subplot(4,6,(bi+18))
            p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 3.8);
            plot(p, 'FaceColor', 'r')
            axis equal
    
            % plot the target position
            hold on
            plot(positions_patients_d(a,1,pi),positions_patients_d(a,2,pi),'p','MarkerFaceColor','b')
    
            % plot the response positions
            hold on
            plot(positions_patients_d(a:(a+3),3,pi),positions_patients_d(a:(a+3),4,pi),'p','MarkerFaceColor','c')
    
            a = a + 4;
    
            title([num2str(patients(pi)),'-Desktop ', num2str(bi) '. Block' ])        

        end    
        
        saveas(h,fullfile(path,sprintf('DistanceError%d.png',pi/2)));
        
    end 

end


% iterate over controls
for ci = 1:16
    
    if rem(ci,2) == 1
        
       k = figure;
       set(gcf, 'Position', get(0, 'Screensize'));
       
        a = 1;
        % iterate over blocks
        for bi = 1:6

    
            % 1. Control-MoBI
    
            % plot the arena
            subplot(4,6,bi)
            p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 3.8);
            plot(p, 'FaceColor', 'r')
            axis equal
    
            % plot the target position
            hold on
            plot(positions_controls_m(a,1,ci),positions_controls_m(a,2,ci),'p','MarkerFaceColor','b')
    
            % plot the response positions
            hold on
            plot(positions_controls_m(a:(a+3),3,ci),positions_controls_m(a:(a+3),4,ci),'p','MarkerFaceColor','c')
        
    
            title([num2str(controls(ci)),'-MoBI ', num2str(bi) '. Block' ])
    
    
            % 2. Control-Desktop
    
            % plot the arena
            subplot(4,6,(bi+6))
            p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 3.8);
            plot(p, 'FaceColor', 'r')
            axis equal
    
            % plot the target position
            hold on
            plot(positions_controls_d(a,1,ci),positions_controls_d(a,2,ci),'p','MarkerFaceColor','b')
    
            % plot the response positions
            hold on
            plot(positions_controls_d(a:(a+3),3,ci),positions_controls_d(a:(a+3),4,ci),'p','MarkerFaceColor','c')
    
            a = a + 4;
    
            title([num2str(controls(ci)),'-Desktop ', num2str(bi) '. Block' ])        

        end     
        
        
    else
        
        a = 1;
        % iterate over blocks
        for bi = 1:6

    
            % 1. Control-MoBI
    
            % plot the arena
            subplot(4,6,(bi+12))
            p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 3.8);
            plot(p, 'FaceColor', 'r')
            axis equal
    
            % plot the target position
            hold on
            plot(positions_controls_m(a,1,ci),positions_controls_m(a,2,ci),'p','MarkerFaceColor','b')
    
            % plot the response positions
            hold on
            plot(positions_controls_m(a:(a+3),3,ci),positions_controls_m(a:(a+3),4,ci),'p','MarkerFaceColor','c')
        
    
            title([num2str(controls(ci)),'-MoBI ', num2str(bi) '. Block' ])
    
    
            % 2. Control-Desktop
    
            % plot the arena
            subplot(4,6,(bi+18))
            p = nsidedpoly(1000, 'Center', [0 0], 'Radius', 3.8);
            plot(p, 'FaceColor', 'r')
            axis equal
    
            % plot the target position
            hold on
            plot(positions_controls_d(a,1,ci),positions_controls_d(a,2,ci),'p','MarkerFaceColor','b')
    
            % plot the response positions
            hold on
            plot(positions_controls_d(a:(a+3),3,ci),positions_controls_d(a:(a+3),4,ci),'p','MarkerFaceColor','c')
    
            a = a + 4;
    
            title([num2str(controls(ci)),'-Desktop ', num2str(bi) '. Block' ])        

        end        
        
        saveas(k,fullfile(path,sprintf('DistanceError%d.png',((ci/2)+5))));
        
    end   

end
