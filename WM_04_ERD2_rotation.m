function [rotation_var_fm, rotation_var_allEloc, rotation_erd_fm, rotation_erd_allEloc] = WM_04_ERD2_rotation(epochedEEG, epochedEEG_baseline)
% it calculates the intertrial variance values of one participant for rotation
% and stores them in seperated matricies
% it doesn't include erd values and calculation


    % 1. Create matricies for rotated and unrotared retrieval trials
    %-------------------------------------------------------------------
    
    
    % loop over session to calculate power seperately
    for session_idx = 1:2 % 1:MoBI 2:Desktop  
    
        
        % find roation epochs
        %------------------------------------------------
        
        % select the all epochs indicies in the sessions
        epochs_trials   = [];
        a = 1;
        for event_idx = 1:numel(epochedEEG.event(:))
            if epochedEEG.event(event_idx).session == session_idx
                epochs_trials(a) = event_idx;
                a = a + 1;
            end
        end    
              
        
        retrieval_epochs  = [];
        ep_0  = [];
        ep_90  = [];
        ep_180 = [];
        ep_270 = [];
        
        % find retrieval event indicies in the sessions
        x = 1;
        
        for idx = 1:numel(epochs_trials)
            
            if contains({epochedEEG.event(epochs_trials(idx)).type}, 'guesstrial:start') == 1
                retrieval_epochs(x) = epochs_trials(idx);
                x = x + 1;
            end
            
        end  
        
        
        % find rotated and unrotated trials for retrieval
        
        a = 1;
        b = 1;
        c = 1;
        d = 1;

        for idx = 1:numel(retrieval_epochs)  
            if epochedEEG.event(retrieval_epochs(idx)).rotation == 0
                ep_0(a) = epochedEEG.event(retrieval_epochs(idx)).epoch;
                a = a + 1; 
            elseif epochedEEG.event(retrieval_epochs(idx)).rotation == 90
                ep_90(b) = epochedEEG.event(retrieval_epochs(idx)).epoch;
                b = b + 1;  
            elseif epochedEEG.event(retrieval_epochs(idx)).rotation == 180
                ep_180(c) = epochedEEG.event(retrieval_epochs(idx)).epoch;
                c = c + 1;
            elseif epochedEEG.event(retrieval_epochs(idx)).rotation == 270
                ep_270(d) = epochedEEG.event(retrieval_epochs(idx)).epoch; 
                d = d + 1;  
            end    
        end
        
        
        % find baseline epoch indicies in the sessions
        baseline_epochs = [];
        d = 1;
        for i = 1:numel(epochedEEG_baseline.epoch(:))
            if session_idx == 1
                if any(strcmp(epochedEEG_baseline.epoch(i).eventtype, 'X1'))
                    baseline_epochs(d) = i;
                    d = d + 1;
                end    
            else
                if any(strcmp(epochedEEG_baseline.epoch(i).eventtype, 'X2'))
                    baseline_epochs(d) = i;
                    d = d + 1;
                end
            end
        end
        
        
        % 2. calculate intertrial variance
        %--------------------------------------------------
        
        
        % all electrodes
        %---------------
        
        % take the average across trials
        
        % 0 rotation 
        if session_idx == 1
            rot0_avg_MoBI = mean(epochedEEG.data(:,:,ep_0), 3);
        else
            rot0_avg_Desk = mean(epochedEEG.data(:,:,ep_0), 3);    
        end    

        
        % 90 rotation 
        if session_idx == 1
            rot90_avg_MoBI = mean(epochedEEG.data(:,:,ep_90), 3);
        else
            rot90_avg_Desk = mean(epochedEEG.data(:,:,ep_90), 3);
        end    

        
        % 180 rotation 
        if session_idx == 1
            rot180_avg_MoBI = mean(epochedEEG.data(:,:,ep_180), 3);
        else
            rot180_avg_Desk = mean(epochedEEG.data(:,:,ep_180), 3);
        end    
        
        
        % 270 rotation 
        if session_idx == 1
            rot270_avg_MoBI = mean(epochedEEG.data(:,:,ep_270), 3);
        else
            rot270_avg_Desk = mean(epochedEEG.data(:,:,ep_270), 3);
        end    
        
        
        % baseline epochs:
        if session_idx == 1
            baseline_avg_MoBI = mean(epochedEEG_baseline.data(:,:,baseline_epochs), 3);       
        else
            baseline_avg_Desk = mean(epochedEEG_baseline.data(:,:,baseline_epochs), 3);
        end    
        
        
        % Compute point-to-point intertrial variance 
        % by subtracting average time course from data samples
        % then take their square
        
        % 0 rotation
        for x = 1:numel(ep_0) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot0_sqr_MoBI(eloc,:,x) = (epochedEEG.data(eloc,:,ep_0(x)) - rot0_avg_MoBI(eloc,:)).^2;
                   else
                       rot0_sqr_Desk(eloc,:,x) = (epochedEEG.data(eloc,:,ep_0(x)) - rot0_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
        
        
        % 90 rotation
        for y = 1:numel(ep_90) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot90_sqr_MoBI(eloc,:,y) = (epochedEEG.data(eloc,:,ep_90(y)) - rot90_avg_MoBI(eloc,:)).^2;
                   else
                       rot90_sqr_Desk(eloc,:,y) = (epochedEEG.data(eloc,:,ep_90(y)) - rot90_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
        
        
        % 180 rotation
        for z = 1:numel(ep_180) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot180_sqr_MoBI(eloc,:,z) = (epochedEEG.data(eloc,:,ep_180(z)) - rot180_avg_MoBI(eloc,:)).^2;
                   else
                       rot180_sqr_Desk(eloc,:,z) = (epochedEEG.data(eloc,:,ep_180(z)) - rot180_avg_Desk(eloc,:)).^2;   
                   end
           end   
        end
                   
        
        % 270 rotation
        for q = 1:numel(ep_270) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot270_sqr_MoBI(eloc,:,q) = (epochedEEG.data(eloc,:,ep_270(q)) - rot270_avg_MoBI(eloc,:)).^2;
                   else
                       rot270_sqr_Desk(eloc,:,q) = (epochedEEG.data(eloc,:,ep_270(q)) - rot270_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
        
        
        % calculate the number of epochs in each session for later
        % calculations
        if session_idx == 1
            n_rot0_MoBI   = numel(ep_0);
            n_rot90_MoBI  = numel(ep_90);
            n_rot180_MoBI = numel(ep_180);
            n_rot270_MoBI = numel(ep_270);
            
        else
            n_rot0_Desk   = numel(ep_0);
            n_rot90_Desk  = numel(ep_90);
            n_rot180_Desk = numel(ep_180);
            n_rot270_Desk = numel(ep_270);
            
        end
        
        
        % baseline epochs:
        
        % iterate over baseline epochs
        for b = 1:numel(baseline_epochs)
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        baseline_sqr_MoBI(eloc,:,b) = (epochedEEG_baseline.data(eloc,:,baseline_epochs(b)) - baseline_avg_MoBI(eloc,:)).^2;
                    else
                        baseline_sqr_Desk(eloc,:,b) = (epochedEEG_baseline.data(eloc,:,baseline_epochs(b)) - baseline_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        
        % calculate the number of baseline epochs in each session for later calculations
        if session_idx == 1
            n_baseline_MoBI = numel(baseline_epochs);
        else
            n_baseline_Desk = numel(baseline_epochs);
        end
        

    end
    
    
    % take the average over trials
    rotation_var_allEloc(:,:,1) = sum(rot0_sqr_MoBI,3)/(n_rot0_MoBI - 1);
    rotation_var_allEloc(:,:,2) = sum(rot0_sqr_Desk,3)/(n_rot0_Desk - 1);
    rotation_var_allEloc(:,:,3) = sum(rot90_sqr_MoBI,3)/(n_rot90_MoBI - 1);
    rotation_var_allEloc(:,:,4) = sum(rot90_sqr_Desk,3)/(n_rot90_Desk - 1);
    rotation_var_allEloc(:,:,5) = sum(rot180_sqr_MoBI,3)/(n_rot180_MoBI - 1);
    rotation_var_allEloc(:,:,6) = sum(rot180_sqr_Desk,3)/(n_rot180_Desk - 1);
    rotation_var_allEloc(:,:,7) = sum(rot270_sqr_MoBI,3)/(n_rot270_MoBI - 1);
    rotation_var_allEloc(:,:,8) = sum(rot270_sqr_Desk,3)/(n_rot270_Desk - 1);
    
    
    % baseline-MoBI
    baseline_mobi(:,:) = sum(baseline_sqr_MoBI,3)/(n_baseline_MoBI - 1);
        
    % baseline-Desktop
    baseline_desk(:,:) = sum(baseline_sqr_Desk,3)/(n_baseline_Desk - 1);
        
    
    % 3. Create a matrix that includes variance of only interested electrodes
    %------------------------------------------------------------------------
    
    
    % interested eloctrode names: {'y1','y2','y3','y25','y32'}
    eloc = [33,34,35,57,64];
    
    rotation_var_fm = rotation_var_allEloc(eloc,:,:);
    
    
    
    % 4. Calculate ERD/ERS for all electrodes
    %------------------------------------------------------------------------
    
    rotation_erd_allEloc(:,:,1)  = (rotation_var_allEloc(:,:,1) - baseline_mobi)./baseline_mobi.*100;
    rotation_erd_allEloc(:,:,2)  = (rotation_var_allEloc(:,:,2) - baseline_desk)./baseline_desk.*100;
    rotation_erd_allEloc(:,:,3)  = (rotation_var_allEloc(:,:,3) - baseline_mobi)./baseline_mobi.*100;
    rotation_erd_allEloc(:,:,4)  = (rotation_var_allEloc(:,:,4) - baseline_desk)./baseline_desk.*100;
    rotation_erd_allEloc(:,:,5)  = (rotation_var_allEloc(:,:,5) - baseline_mobi)./baseline_mobi.*100;
    rotation_erd_allEloc(:,:,6)  = (rotation_var_allEloc(:,:,6) - baseline_desk)./baseline_desk.*100;
    rotation_erd_allEloc(:,:,7)  = (rotation_var_allEloc(:,:,7) - baseline_mobi)./baseline_mobi.*100;
    rotation_erd_allEloc(:,:,8)  = (rotation_var_allEloc(:,:,8) - baseline_desk)./baseline_desk.*100;
    
    
    % Calculate ERD/ERS for only interested electrodes
    
    rotation_erd_fm(:,:,:) = rotation_erd_allEloc(eloc,:,:); 
   
    

end