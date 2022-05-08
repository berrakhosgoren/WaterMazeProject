function [variance_fm, variance_allEloc, erd_fm, erd_allEloc, var_epoch_enc, var_epoch_ret] = WM_04_ERD1_main(epochedEEG,epochedEEG_baseline)
% it calculates the intertrial variance and ERD values of one participant 
% and stores them in seperated matricies

    
    % rows: electrodes
    % columns: time points
    % 3rd dimension: encoding_all-MoBI, encoding_all-Desktop, encoding_2_3-MoBI, encoding_2_3-Desktop,
    % retrieval_guess-MoBI, retrieval_guess-Desktop, retrieval_search-MoBI, retrieval_seach-Desktop,
    % retrieval_all-MoBI,retrieval_all-Desktop, baseline-MoBI, baseline-Desktop

    % encoding_all includes all search trials
    % encoding_2_3 exludes the first search trial
    % retrieval_guess includes all guess trials starts
    % retrieval_search includes 2 & 3 search trials starts
    % retrieval_all includes both guess and search trials starts (except
    % the first search trial)
    
    
    variance_allEloc = []; % all electrodes
    
    
    enc_all_avg_MoBI    = [];
    enc_all_avg_Desk    = [];
    enc_2_3_avg_MoBI    = [];
    enc_2_3_avg_Desk    = [];
    ret_guess_avg_MoBI  = [];
    ret_guess_avg_Desk  = [];
    ret_search_avg_MoBI = [];
    ret_search_avg_Desk = [];
    ret_all_avg_MoBI    = [];
    ret_all_avg_Desk    = [];
    baseline_avg_MoBI   = [];
    baseline_avg_Desk   = [];
         
    enc_all_sqr_MoBI    = [];
    enc_all_sqr_Desk    = [];
    enc_2_3_sqr_MoBI    = [];
    enc_2_3_sqr_Desk    = [];
    ret_guess_sqr_MoBI  = [];
    ret_guess_sqr_Desk  = [];
    ret_search_sqr_MoBI = [];
    ret_search_sqr_Desk = [];
    ret_all_sqr_MoBI    = [];
    ret_all_sqr_Desk    = [];
    baseline_sqr_MoBI   = [];
    baseline_sqr_Desk   = [];
        

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
        
        encoding_all_epochs    =  [];
        encoding_2_3_epochs    =  [];
        retrieval_guess_epochs =  [];
        retrieval_search_epochs = [];
        
        % find encoding and retrieval epoch indicies in the sessions
        b = 1;
        c = 1;
        for idx = 1:numel(epochs_trials)
            if contains({epochedEEG.event(epochs_trials(idx)).type}, 'searchtrial:found') == 1
                encoding_all_epochs(b) = epochedEEG.event(epochs_trials(idx)).epoch;
                b = b + 1;
            elseif contains({epochedEEG.event(epochs_trials(idx)).type}, 'guesstrial:start') == 1
                retrieval_guess_epochs(c) = epochedEEG.event(epochs_trials(idx)).epoch;
                c = c + 1;
            end
        end    
        
        x = 1;
        y = 1;
        for idx = 1:numel(epochs_trials)
            if contains({epochedEEG.event(epochs_trials(idx)).type}, 'searchtrial:found') == 1 && epochedEEG.event(epochs_trials(idx)).order ~= 1
                encoding_2_3_epochs(x) = epochedEEG.event(epochs_trials(idx)).epoch;
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
        
        %
        %------------------------------------------------------------------
        % take the average across trials 
        
        % encoding_all epochs:
        if session_idx == 1
            enc_all_avg_MoBI = mean(epochedEEG.data(:,:,encoding_all_epochs), 3);
        else
            enc_all_avg_Desk = mean(epochedEEG.data(:,:,encoding_all_epochs), 3);
        end    
        
        % encoding_2_3 epochs:
        if session_idx == 1
            enc_2_3_avg_MoBI = mean(epochedEEG.data(:,:,encoding_2_3_epochs), 3);
        else
            enc_2_3_avg_Desk = mean(epochedEEG.data(:,:,encoding_2_3_epochs), 3);
        end   
        
        
        % retrieval_guess epochs:
        if session_idx == 1
            ret_guess_avg_MoBI = mean(epochedEEG.data(:,:,retrieval_guess_epochs), 3);       
        else
            ret_guess_avg_Desk = mean(epochedEEG.data(:,:,retrieval_guess_epochs), 3);     
        end      
        
        % retrieval_search epochs:
        if session_idx == 1
            ret_search_avg_MoBI = mean(epochedEEG.data(:,:,retrieval_search_epochs), 3);       
        else
            ret_search_avg_Desk = mean(epochedEEG.data(:,:,retrieval_search_epochs), 3);     
        end   
        
        % retrieval_all epochs:
        if session_idx == 1
            ret_all_avg_MoBI = mean(epochedEEG.data(:,:,retrieval_all_epochs), 3);       
        else
            ret_all_avg_Desk = mean(epochedEEG.data(:,:,retrieval_all_epochs), 3);     
        end               

        
        % baseline epochs:
        if session_idx == 1
            baseline_avg_MoBI = mean(epochedEEG_baseline.data(:,:,baseline_epochs), 3);       
        else
            baseline_avg_Desk = mean(epochedEEG_baseline.data(:,:,baseline_epochs), 3);
        end    
%
        
        %----------------------------------------------------------
        % Compute point-to-point intertrial variance 
        % by subtracting average time course from data samples
        % then take their square

        
        % encoding epochs:
        
        % iterate over encoding_all epochs
        for e = 1:18
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        enc_all_sqr_MoBI(eloc,:,e) = (epochedEEG.data(eloc,:,encoding_all_epochs(e)) - enc_all_avg_MoBI(eloc,:)).^2;
                    else
                        enc_all_sqr_Desk(eloc,:,e) = (epochedEEG.data(eloc,:,encoding_all_epochs(e)) - enc_all_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        % iterate over encoding_2_3 epochs
        for e = 1:12
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        enc_2_3_sqr_MoBI(eloc,:,e) = (epochedEEG.data(eloc,:,encoding_2_3_epochs(e)) - enc_2_3_avg_MoBI(eloc,:)).^2;
                    else
                        enc_2_3_sqr_Desk(eloc,:,e) = (epochedEEG.data(eloc,:,encoding_2_3_epochs(e)) - enc_2_3_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        
        
        % retrieval epochs:
        
        % iterate over retrieval_guess epochs
        for r = 1:24
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        ret_guess_sqr_MoBI(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_guess_epochs(r)) - ret_guess_avg_MoBI(eloc,:)).^2;
                    else
                        ret_guess_sqr_Desk(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_guess_epochs(r)) - ret_guess_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        % iterate over retrieval_search epochs
        for r = 1:12
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        ret_search_sqr_MoBI(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_search_epochs(r)) - ret_search_avg_MoBI(eloc,:)).^2;
                    else
                        ret_search_sqr_Desk(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_search_epochs(r)) - ret_search_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        % iterate over retrieval_all epochs
        for r = 1:36
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        ret_all_sqr_MoBI(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_all_epochs(r)) - ret_all_avg_MoBI(eloc,:)).^2;
                    else
                        ret_all_sqr_Desk(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_all_epochs(r)) - ret_all_avg_Desk(eloc,:)).^2;
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
            
    %---------------------------------------------------
    % take the average over trials
        
    
    % encoding_all-MoBI
    variance_allEloc(:,:,1) = sum(enc_all_sqr_MoBI,3)/17;
        
    % encoding_all-Desk
    variance_allEloc(:,:,2) = sum(enc_all_sqr_Desk,3)/17;
    
    % encoding_2_3-MoBI
    variance_allEloc(:,:,3) = sum(enc_2_3_sqr_MoBI,3)/11;
        
    % encoding_2_3-Desk
    variance_allEloc(:,:,4) = sum(enc_2_3_sqr_Desk,3)/11;
           
    % retrieval_guess-MoBI
    variance_allEloc(:,:,5) = sum(ret_guess_sqr_MoBI,3)/23;
        
    % retrieval_guess-Desk
    variance_allEloc(:,:,6) = sum(ret_guess_sqr_Desk,3)/23;
    
    % retrieval_search-MoBI
    variance_allEloc(:,:,7) = sum(ret_search_sqr_MoBI,3)/11;
        
    % retrieval_search-Desk
    variance_allEloc(:,:,8) = sum(ret_search_sqr_Desk,3)/11;
    
    % retrieval_all-MoBI
    variance_allEloc(:,:,9) = sum(ret_all_sqr_MoBI,3)/35;
        
    % retrieval_all-Desk
    variance_allEloc(:,:,10) = sum(ret_all_sqr_Desk,3)/35;
        
    % baseline-MoBI
    variance_allEloc(:,:,11) = sum(baseline_sqr_MoBI,3)/(n_baseline_MoBI - 1);
        
    % baseline-Desktop
    variance_allEloc(:,:,12) = sum(baseline_sqr_Desk,3)/(n_baseline_Desk - 1);
  
    
    
    % 2. Create a matrix that includes variance of only interested electrodes
    %---------------------------------------------------------------------
    
    % interested eloctrode names: {'y1','y2','y3','y25','y32'}
    eloc = [33,34,35,57,64];
    
    variance_fm = variance_allEloc(eloc,:,:);

    
    % 3. Calculate ERD/ERS for all electrodes
    %------------------------------------------------------------------

    % encoding_all-MoBI
    erd_allEloc(:,:,1) = ((variance_allEloc(:,:,1) - variance_allEloc(:,:,11))./variance_allEloc(:,:,11)).*100;
        
    % encoding_all-Desk
    erd_allEloc(:,:,2) = ((variance_allEloc(:,:,2) - variance_allEloc(:,:,12))./variance_allEloc(:,:,12)).*100;
           
    % encoding_2_3-MoBI
    erd_allEloc(:,:,3) = ((variance_allEloc(:,:,3) - variance_allEloc(:,:,11))./variance_allEloc(:,:,11)).*100;
        
    % encoding_2_3-Desk
    erd_allEloc(:,:,4) = ((variance_allEloc(:,:,4) - variance_allEloc(:,:,12))./variance_allEloc(:,:,12)).*100;
        
    % retrieval_guess-MoBI
    erd_allEloc(:,:,5) = ((variance_allEloc(:,:,5) - variance_allEloc(:,:,11))./variance_allEloc(:,:,11)).*100;
        
    % retrieval_guess-Desk
    erd_allEloc(:,:,6) = ((variance_allEloc(:,:,6) - variance_allEloc(:,:,12))./variance_allEloc(:,:,12)).*100;
    
    % retrieval_search-MoBI
    erd_allEloc(:,:,7) = ((variance_allEloc(:,:,7) - variance_allEloc(:,:,11))./variance_allEloc(:,:,11)).*100;
        
    % retrieval_search-Desk
    erd_allEloc(:,:,8) = ((variance_allEloc(:,:,8) - variance_allEloc(:,:,12))./variance_allEloc(:,:,12)).*100;
           
    % retrieval_all-MoBI
    erd_allEloc(:,:,9) = ((variance_allEloc(:,:,9) - variance_allEloc(:,:,11))./variance_allEloc(:,:,11)).*100;
        
    % retrieval_all-Desk
    erd_allEloc(:,:,10) = ((variance_allEloc(:,:,10) - variance_allEloc(:,:,12))./variance_allEloc(:,:,12)).*100;
        
    
    
    % 4. Calculate ERD/ERS for only interested electrodes
    %-------------------------------------------------------------------
    
    erd_fm(:,:,:) = erd_allEloc(eloc,:,:); 
       
    
    
    % 5. Create intertrial variance matricies without averaging over trials
    %--------------------------------------------------------------------
    
    % take their average over time points and electrodes
    % only interested electrodes
    % Note: it is done for regression analysis in participant bases 
    
    
    % var_epoch_enc:
    % 1. column = encoding_all-MoBI
    % 2. column = encoding_all-Desk
    % 3. column = encoding_2_3-MoBI
    % 4. column = encoding_2_3-Desk
    
    % var_epoch_ret:
    % 1. column = retrieval_guess-MoBI
    % 2. column = retrieval_guess-Desk
    % 3. column = retireval_search-MoBI
    % 4. column = retrieval_search-Desk
    % 5. column = retireval_all-MoBI
    % 6. column = retrieval_all-Desk
    
    for en = 1:18 % loop over encoding_all trials
        
        var_epoch_enc(en,1) = mean(enc_all_sqr_MoBI(eloc,:,en),'all');
        var_epoch_enc(en,2) = mean(enc_all_sqr_Desk(eloc,:,en),'all');
        
    end
    
    for en = 1:12 % loop over encoding_2_3 trials
        
        var_epoch_enc(en,3) = mean(enc_2_3_sqr_MoBI(eloc,:,en),'all');
        var_epoch_enc(en,4) = mean(enc_2_3_sqr_Desk(eloc,:,en),'all');
        
    end
    
    
    for re = 1:24 % loop over retrieval_guess trials
        
        var_epoch_ret(re,1) = mean(ret_guess_sqr_MoBI(eloc,:,re),'all');
        var_epoch_ret(re,2) = mean(ret_guess_sqr_Desk(eloc,:,re),'all');
        
    end
    
    for re = 1:12 % loop over retrieval_search trials
        
        var_epoch_ret(re,3) = mean(ret_search_sqr_MoBI(eloc,:,re),'all');
        var_epoch_ret(re,4) = mean(ret_search_sqr_Desk(eloc,:,re),'all');
        
    end
    
    for re = 1:36 % loop over retrieval_all trials
        
        var_epoch_ret(re,5) = mean(ret_all_sqr_MoBI(eloc,:,re),'all');
        var_epoch_ret(re,6) = mean(ret_all_sqr_Desk(eloc,:,re),'all');
        
    end    
    
    
    
end