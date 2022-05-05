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
              
        
        retrieval_guess_epochs  = [];
        retrieval_search_epochs = [];
        ep_0_guess = [];
        ep_90_guess = [];
        ep_180_guess = [];
        ep_270_guess = [];
        ep_0_all = [];
        ep_90_all = [];
        ep_180_all = [];
        ep_270_all = [];
        
        % find retrieval event indicies in the sessions
        x = 1;
        y = 1;
        
        for idx = 1:numel(epochs_trials)
            
            if contains({epochedEEG.event(epochs_trials(idx)).type}, 'guesstrial:start') == 1
                retrieval_guess_epochs(x) = epochs_trials(idx);
                x = x + 1;
            elseif contains({epochedEEG.event(epochs_trials(idx)).type}, 'searchtrial:start') == 1 && epochedEEG.event(epochs_trials(idx)).order ~= 1
                retrieval_search_epochs(y) = epochedEEG.event(epochs_trials(idx)).epoch;
                y = y + 1;       
            end
            
        end  
        
        % add retrieval guess and search epoch indicies
        retrieval_all_epochs = [retrieval_guess_epochs, retrieval_search_epochs];
        
        % sort the epoch indicies
        retrieval_all_epochs = sort(retrieval_all_epochs);
        
        
        % find rotated and unrotated trials for retrieval_guess
        
        a = 1;
        b = 1;
        c = 1;
        d = 1;

        for idx = 1:numel(retrieval_guess_epochs)  
            if epochedEEG.event(retrieval_guess_epochs(idx)).rotation == 0
                ep_0_guess(a) = epochedEEG.event(retrieval_guess_epochs(idx)).epoch;
                a = a + 1; 
            elseif epochedEEG.event(retrieval_guess_epochs(idx)).rotation == 90
                ep_90_guess(b) = epochedEEG.event(retrieval_guess_epochs(idx)).epoch;
                b = b + 1;  
            elseif epochedEEG.event(retrieval_guess_epochs(idx)).rotation == 180
                ep_180_guess(c) = epochedEEG.event(retrieval_guess_epochs(idx)).epoch;
                c = c + 1;
            elseif epochedEEG.event(retrieval_guess_epochs(idx)).rotation == 270
                ep_270_guess(d) = epochedEEG.event(retrieval_guess_epochs(idx)).epoch; 
                d = d + 1;  
            end    
        end
        
        
        % find rotated and unrotated trials for retrieval_all
        e = 1;
        f = 1;
        g = 1;
        h = 1;
        
        for idx = 1:numel(retrieval_all_epochs)  
            if epochedEEG.event(retrieval_all_epochs(idx)).rotation == 0
                ep_0_all(e) = epochedEEG.event(retrieval_all_epochs(idx)).epoch;
                e = e + 1; 
            elseif epochedEEG.event(retrieval_all_epochs(idx)).rotation == 90
                ep_90_all(f) = epochedEEG.event(retrieval_all_epochs(idx)).epoch;
                f = f + 1;  
            elseif epochedEEG.event(retrieval_all_epochs(idx)).rotation == 180
                ep_180_all(g) = epochedEEG.event(retrieval_all_epochs(idx)).epoch;
                g = g + 1;
            elseif epochedEEG.event(retrieval_all_epochs(idx)).rotation == 270
                ep_270_all(h) = epochedEEG.event(retrieval_all_epochs(idx)).epoch; 
                h = h + 1;  
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
            rot0_guess_avg_MoBI = mean(epochedEEG.data(:,:,ep_0_guess), 3);
            rot0_all_avg_MoBI = mean(epochedEEG.data(:,:,ep_0_all), 3);
        else
            rot0_guess_avg_Desk = mean(epochedEEG.data(:,:,ep_0_guess), 3);   
            rot0_all_avg_Desk = mean(epochedEEG.data(:,:,ep_0_all), 3);  
        end    

        
        % 90 rotation 
        if session_idx == 1
            rot90_guess_avg_MoBI = mean(epochedEEG.data(:,:,ep_90_guess), 3);
            rot90_all_avg_MoBI = mean(epochedEEG.data(:,:,ep_90_all), 3);
        else
            rot90_guess_avg_Desk = mean(epochedEEG.data(:,:,ep_90_guess), 3);
            rot90_all_avg_Desk = mean(epochedEEG.data(:,:,ep_90_all), 3);
        end    

        
        % 180 rotation 
        if session_idx == 1
            rot180_guess_avg_MoBI = mean(epochedEEG.data(:,:,ep_180_guess), 3);
            rot180_all_avg_MoBI = mean(epochedEEG.data(:,:,ep_180_all), 3);
        else
            rot180_guess_avg_Desk = mean(epochedEEG.data(:,:,ep_180_guess), 3);
            rot180_all_avg_Desk = mean(epochedEEG.data(:,:,ep_180_all), 3);
        end    
        
        
        % 270 rotation 
        if session_idx == 1
            rot270_guess_avg_MoBI = mean(epochedEEG.data(:,:,ep_270_guess), 3);
            rot270_all_avg_MoBI = mean(epochedEEG.data(:,:,ep_270_all), 3);
        else
            rot270_guess_avg_Desk = mean(epochedEEG.data(:,:,ep_270_guess), 3);
            rot270_all_avg_Desk = mean(epochedEEG.data(:,:,ep_270_all), 3);
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
        for x = 1:numel(ep_0_guess) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot0_guess_sqr_MoBI(eloc,:,x) = (epochedEEG.data(eloc,:,ep_0_guess(x)) - rot0_guess_avg_MoBI(eloc,:)).^2;
                   else
                       rot0_guess_sqr_Desk(eloc,:,x) = (epochedEEG.data(eloc,:,ep_0_guess(x)) - rot0_guess_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
        
        for x = 1:numel(ep_0_all) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot0_all_sqr_MoBI(eloc,:,x) = (epochedEEG.data(eloc,:,ep_0_all(x)) - rot0_all_avg_MoBI(eloc,:)).^2;
                   else
                       rot0_all_sqr_Desk(eloc,:,x) = (epochedEEG.data(eloc,:,ep_0_all(x)) - rot0_all_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
        
        
        % 90 rotation
        for y = 1:numel(ep_90_guess) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot90_guess_sqr_MoBI(eloc,:,y) = (epochedEEG.data(eloc,:,ep_90_guess(y)) - rot90_guess_avg_MoBI(eloc,:)).^2;
                   else
                       rot90_guess_sqr_Desk(eloc,:,y) = (epochedEEG.data(eloc,:,ep_90_guess(y)) - rot90_guess_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
        
        for y = 1:numel(ep_90_all) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot90_all_sqr_MoBI(eloc,:,y) = (epochedEEG.data(eloc,:,ep_90_all(y)) - rot90_all_avg_MoBI(eloc,:)).^2;
                   else
                       rot90_all_sqr_Desk(eloc,:,y) = (epochedEEG.data(eloc,:,ep_90_all(y)) - rot90_all_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
        
        
        % 180 rotation
        for z = 1:numel(ep_180_guess) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot180_guess_sqr_MoBI(eloc,:,z) = (epochedEEG.data(eloc,:,ep_180_guess(z)) - rot180_guess_avg_MoBI(eloc,:)).^2;
                   else
                       rot180_guess_sqr_Desk(eloc,:,z) = (epochedEEG.data(eloc,:,ep_180_guess(z)) - rot180_guess_avg_Desk(eloc,:)).^2;   
                   end
           end   
        end
        
        for z = 1:numel(ep_180_all) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot180_all_sqr_MoBI(eloc,:,z) = (epochedEEG.data(eloc,:,ep_180_all(z)) - rot180_all_avg_MoBI(eloc,:)).^2;
                   else
                       rot180_all_sqr_Desk(eloc,:,z) = (epochedEEG.data(eloc,:,ep_180_all(z)) - rot180_all_avg_Desk(eloc,:)).^2;   
                   end
           end   
        end                                               
                                
        
        % 270 rotation
        for q = 1:numel(ep_270_guess) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot270_guess_sqr_MoBI(eloc,:,q) = (epochedEEG.data(eloc,:,ep_270_guess(q)) - rot270_guess_avg_MoBI(eloc,:)).^2;
                   else
                       rot270_guess_sqr_Desk(eloc,:,q) = (epochedEEG.data(eloc,:,ep_270_guess(q)) - rot270_guess_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
        
        for q = 1:numel(ep_270_all) % iterate over epochs
           for eloc = 1:128 % iterate over electrodes 
                   if session_idx == 1
                       rot270_all_sqr_MoBI(eloc,:,q) = (epochedEEG.data(eloc,:,ep_270_all(q)) - rot270_all_avg_MoBI(eloc,:)).^2;
                   else
                       rot270_all_sqr_Desk(eloc,:,q) = (epochedEEG.data(eloc,:,ep_270_all(q)) - rot270_all_avg_Desk(eloc,:)).^2;
                   end
           end   
        end
       
        
        % calculate the number of epochs in each session for later
        % calculations
        if session_idx == 1
            n_rot0_MoBI_guess   = numel(ep_0_guess);
            n_rot90_MoBI_guess  = numel(ep_90_guess);
            n_rot180_MoBI_guess = numel(ep_180_guess);
            n_rot270_MoBI_guess = numel(ep_270_guess);
            
            n_rot0_MoBI_all   = numel(ep_0_all);
            n_rot90_MoBI_all  = numel(ep_90_all);
            n_rot180_MoBI_all = numel(ep_180_all);
            n_rot270_MoBI_all = numel(ep_270_all);
            
        else
            n_rot0_Desk_guess   = numel(ep_0_guess);
            n_rot90_Desk_guess  = numel(ep_90_guess);
            n_rot180_Desk_guess = numel(ep_180_guess);
            n_rot270_Desk_guess = numel(ep_270_guess);
            
            n_rot0_Desk_all   = numel(ep_0_all);
            n_rot90_Desk_all  = numel(ep_90_all);
            n_rot180_Desk_all = numel(ep_180_all);
            n_rot270_Desk_all = numel(ep_270_all);
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
    rotation_var_allEloc(:,:,1) = sum(rot0_guess_sqr_MoBI,3)/(n_rot0_MoBI_guess - 1);
    rotation_var_allEloc(:,:,2) = sum(rot0_guess_sqr_Desk,3)/(n_rot0_Desk_guess - 1);
    rotation_var_allEloc(:,:,3) = sum(rot90_guess_sqr_MoBI,3)/(n_rot90_MoBI_guess - 1);
    rotation_var_allEloc(:,:,4) = sum(rot90_guess_sqr_Desk,3)/(n_rot90_Desk_guess - 1);
    rotation_var_allEloc(:,:,5) = sum(rot180_guess_sqr_MoBI,3)/(n_rot180_MoBI_guess - 1);
    rotation_var_allEloc(:,:,6) = sum(rot180_guess_sqr_Desk,3)/(n_rot180_Desk_guess - 1);
    rotation_var_allEloc(:,:,7) = sum(rot270_guess_sqr_MoBI,3)/(n_rot270_MoBI_guess - 1);
    rotation_var_allEloc(:,:,8) = sum(rot270_guess_sqr_Desk,3)/(n_rot270_Desk_guess - 1);
    
    rotation_var_allEloc(:,:,9) = sum(rot0_all_sqr_MoBI,3)/(n_rot0_MoBI_all - 1);
    rotation_var_allEloc(:,:,10) = sum(rot0_all_sqr_Desk,3)/(n_rot0_Desk_all - 1);
    rotation_var_allEloc(:,:,11) = sum(rot90_all_sqr_MoBI,3)/(n_rot90_MoBI_all - 1);
    rotation_var_allEloc(:,:,12) = sum(rot90_all_sqr_Desk,3)/(n_rot90_Desk_all - 1);
    rotation_var_allEloc(:,:,13) = sum(rot180_all_sqr_MoBI,3)/(n_rot180_MoBI_all - 1);
    rotation_var_allEloc(:,:,14) = sum(rot180_all_sqr_Desk,3)/(n_rot180_Desk_all - 1);
    rotation_var_allEloc(:,:,15) = sum(rot270_all_sqr_MoBI,3)/(n_rot270_MoBI_all - 1);
    rotation_var_allEloc(:,:,16) = sum(rot270_all_sqr_Desk,3)/(n_rot270_Desk_all - 1);
    
    
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
    rotation_erd_allEloc(:,:,9)  = (rotation_var_allEloc(:,:,9) - baseline_mobi)./baseline_mobi.*100;
    rotation_erd_allEloc(:,:,10) = (rotation_var_allEloc(:,:,10) - baseline_desk)./baseline_desk.*100;
    rotation_erd_allEloc(:,:,11) = (rotation_var_allEloc(:,:,11) - baseline_mobi)./baseline_mobi.*100;
    rotation_erd_allEloc(:,:,12) = (rotation_var_allEloc(:,:,12) - baseline_desk)./baseline_desk.*100;
    rotation_erd_allEloc(:,:,13) = (rotation_var_allEloc(:,:,13) - baseline_mobi)./baseline_mobi.*100;
    rotation_erd_allEloc(:,:,14) = (rotation_var_allEloc(:,:,14) - baseline_desk)./baseline_desk.*100;
    rotation_erd_allEloc(:,:,15) = (rotation_var_allEloc(:,:,15) - baseline_mobi)./baseline_mobi.*100;
    rotation_erd_allEloc(:,:,16) = (rotation_var_allEloc(:,:,16) - baseline_desk)./baseline_desk.*100;
    
    
    % Calculate ERD/ERS for only interested electrodes
    
    rotation_erd_fm(:,:,:) = rotation_erd_allEloc(eloc,:,:); 
   
    

end