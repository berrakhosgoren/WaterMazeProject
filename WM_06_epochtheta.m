function [erd_encoding_2_3, var_epoch_en, var_epoch_re] = WM_06_epochtheta(epochedEEG,epochedEEG_baseline)
%
    variance_allEloc = []; % all electrodes
    
    encoding_avg_MoBI  = [];
    encoding_avg_Desk  = [];
    retrieval_avg_MoBI = [];
    retrieval_avg_Desk = [];
    baseline_avg_MoBI  = [];
    baseline_avg_Desk  = [];
    
    encoding_sqr_MoBI  = [];
    encoding_sqr_Desk  = [];
    retrieval_sqr_MoBI = [];
    retrieval_sqr_Desk = [];
    baseline_sqr_MoBI  = [];
    baseline_sqr_Desk  = [];
    
    erd_encoding_2_3 = [];
    erd_encoding     = [];
    
    
    % 1. Calculate intertrial variance for all electrodes
    %------------------------------------------------------------------------------
    
    % loop over session to calculate the intertrial variance seperately
    for session_idx = 1:2 % 1:MoBI 2:Desktop
        
        % select the all epochs indicies in the sessions
        epochs_trials   = [];
        a = 1;
        for event_idx = 1:numel(epochedEEG.event(:))
            if epochedEEG.event(event_idx).session == session_idx
                epochs_trials(a) = event_idx;
                a = a + 1;
            end
        end        
        
        encoding_epochs  = [];
        retrieval_epochs = [];
        
        % find encoding and retrieval epoch indicies in the sessions
        b = 1;
        c = 1;
        for idx = 1:numel(epochs_trials)
            if contains({epochedEEG.event(epochs_trials(idx)).type}, 'searchtrial:found') == 1 && epochedEEG.event(epochs_trials(idx)).order ~= 1
                encoding_epochs(b) = epochedEEG.event(epochs_trials(idx)).epoch;
                b = b + 1;
            elseif contains({epochedEEG.event(epochs_trials(idx)).type}, 'guesstrial:start') == 1
                retrieval_epochs(c) = epochedEEG.event(epochs_trials(idx)).epoch;
                c = c + 1;
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
        
        
        %------------------------------------------------------------------
        % take the average across trials 
        
        % encoding epochs:
        if session_idx == 1
            encoding_avg_MoBI = mean(epochedEEG.data(:,:,encoding_epochs), 3);
        else
            encoding_avg_Desk = mean(epochedEEG.data(:,:,encoding_epochs), 3);
        end    
        
        
        % retrieval epochs:
        if session_idx == 1
            retrieval_avg_MoBI = mean(epochedEEG.data(:,:,retrieval_epochs), 3);       
        else
            retrieval_avg_Desk = mean(epochedEEG.data(:,:,retrieval_epochs), 3);     
        end               

        
        % baseline epochs:
        if session_idx == 1
            baseline_avg_MoBI = mean(epochedEEG_baseline.data(:,:,baseline_epochs), 3);       
        else
            baseline_avg_Desk = mean(epochedEEG_baseline.data(:,:,baseline_epochs), 3);
        end   
        
        
        %----------------------------------------------------------
        % Compute point-to-point intertrial variance 
        % by subtracting average time course from data samples
        % then take their square

        
        % encoding epochs:
        
        % iterate over encoding epochs
        for e = 1:12
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        encoding_sqr_MoBI(eloc,:,e) = (epochedEEG.data(eloc,:,encoding_epochs(e)) - encoding_avg_MoBI(eloc,:)).^2;
                    else
                        encoding_sqr_Desk(eloc,:,e) = (epochedEEG.data(eloc,:,encoding_epochs(e)) - encoding_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        
        % retrieval epochs:
        
        % iterate over retrieval epochs
        for r = 1:24
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        retrieval_sqr_MoBI(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_epochs(r)) - retrieval_avg_MoBI(eloc,:)).^2;
                    else
                        retrieval_sqr_Desk(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_epochs(r)) - retrieval_avg_Desk(eloc,:)).^2;
                    end
            end   
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

    
    % 2. Create an encoding ERD matrix (only 2. and 3. trials) for interested electrodes
    %------------------------------------------------------------------------
    
    
    % take the average over trials
    %-----------------------------
    
    % encoding-MoBI
    variance_allEloc(:,:,1) = sum(encoding_sqr_MoBI,3)/11;
        
    % encoding-Desk
    variance_allEloc(:,:,2) = sum(encoding_sqr_Desk,3)/11;
        
    % baseline-MoBI
    variance_allEloc(:,:,3) = sum(baseline_sqr_MoBI,3)/(n_baseline_MoBI - 1);
        
    % baseline-Desktop
    variance_allEloc(:,:,4) = sum(baseline_sqr_Desk,3)/(n_baseline_Desk - 1);
    
    
    % interested eloctrode names: {'y1','y2','y3','y25','y32'}
    eloc = [33,34,35,57,64];
    
    variance_fm = variance_allEloc(eloc,:,:);
    
    % calculate erd values
    %---------------------
    
    % encoding-MoBI
    erd_encoding(:,:,1) = ((variance_fm(:,:,1) - variance_fm(:,:,3))./variance_fm(:,:,3)).*100;
        
    % encoding-Desk
    erd_encoding(:,:,2) = ((variance_fm(:,:,2) - variance_fm(:,:,4))./variance_fm(:,:,4)).*100;
    
    % average over electrodes and data points
    %----------------------------------------
    
    erd_encoding_2_3(1,1) = mean(erd_encoding(:,:,1),'all'); % mobi
    erd_encoding_2_3(1,2) = mean(erd_encoding(:,:,2),'all'); % desktop
    
    
    
    % 3. Create intertrial variance matricies without averaging over trials
    %---------------------------------------------------------------------
    
    
    for en = 1:12 % loop over encoding trials
        
        var_epoch_en(en,1) = mean(encoding_sqr_MoBI(:,:,en),'all');
        var_epoch_en(en,2) = mean(encoding_sqr_Desk(:,:,en),'all');
        
    end
    
    
    for re = 1:24 % loop over encoding trials
        
        var_epoch_re(re,1) = mean(retrieval_sqr_MoBI(:,:,re),'all');
        var_epoch_re(re,2) = mean(retrieval_sqr_Desk(:,:,re),'all');
        
    end


end