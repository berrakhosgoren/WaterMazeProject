function [var_epoch_enc_all, var_epoch_enc_2_3, var_epoch_ret_guess,...
    var_epoch_ret_search, var_epoch_ret_all] = WM_04_variance(epochedEEG)
    
    
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

        
        %----------------------------------------------------------
        % Compute point-to-point intertrial variance 
        % by subtracting average time course from data samples
        % then take their square

        
        % encoding epochs:
        
        % iterate over encoding_all epochs
        for e = 1:numel(encoding_all_epochs)
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        enc_all_sqr_MoBI(eloc,:,e) = (epochedEEG.data(eloc,:,encoding_all_epochs(e)) - enc_all_avg_MoBI(eloc,:)).^2;
                    else
                        enc_all_sqr_Desk(eloc,:,e) = (epochedEEG.data(eloc,:,encoding_all_epochs(e)) - enc_all_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        % iterate over encoding_2_3 epochs
        for e = 1:numel(encoding_2_3_epochs)
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
        for r = 1:numel(retrieval_guess_epochs)
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        ret_guess_sqr_MoBI(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_guess_epochs(r)) - ret_guess_avg_MoBI(eloc,:)).^2;
                    else
                        ret_guess_sqr_Desk(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_guess_epochs(r)) - ret_guess_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        % iterate over retrieval_search epochs
        for r = 1:numel(retrieval_search_epochs)
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        ret_search_sqr_MoBI(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_search_epochs(r)) - ret_search_avg_MoBI(eloc,:)).^2;
                    else
                        ret_search_sqr_Desk(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_search_epochs(r)) - ret_search_avg_Desk(eloc,:)).^2;
                    end
            end   
        end
        
        % iterate over retrieval_all epochs
        for r = 1:numel(retrieval_all_epochs)
            for eloc = 1:128 % iterate over electrodes 
                    if session_idx == 1
                        ret_all_sqr_MoBI(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_all_epochs(r)) - ret_all_avg_MoBI(eloc,:)).^2;
                    else
                        ret_all_sqr_Desk(eloc,:,r) = (epochedEEG.data(eloc,:,retrieval_all_epochs(r)) - ret_all_avg_Desk(eloc,:)).^2;
                    end
            end   
        end   
    end
    

    % 2. Create intertrial variance matricies without averaging over trials
    %--------------------------------------------------------------------
    
    % take their average over time points and electrodes
    % only interested electrodes
    % Note: it is done for regression analysis in participant bases 
    
    
    for en = 1:size(enc_all_sqr_MoBI,3) % loop over encoding_all trials
        var_epoch_enc_all(en,1) = mean(enc_all_sqr_MoBI(eloc,:,en),'all');
        var_epoch_enc_all(en,2) = mean(enc_all_sqr_Desk(eloc,:,en),'all');
    end
    
    for en = 1:size(enc_2_3_sqr_MoBI,3) % loop over encoding_2_3 trials
        var_epoch_enc_2_3(en,1) = mean(enc_2_3_sqr_MoBI(eloc,:,en),'all');
        var_epoch_enc_2_3(en,2) = mean(enc_2_3_sqr_Desk(eloc,:,en),'all'); 
    end
    
    for re = 1:size(ret_guess_sqr_MoBI,3) % loop over retrieval_guess trials
        var_epoch_ret_guess(re,1) = mean(ret_guess_sqr_MoBI(eloc,:,re),'all');
        var_epoch_ret_guess(re,2) = mean(ret_guess_sqr_Desk(eloc,:,re),'all');
    end
    
    for re = 1:size(ret_search_sqr_MoBI,3) % loop over retrieval_search trials
        var_epoch_ret_search(re,1) = mean(ret_search_sqr_MoBI(eloc,:,re),'all');
        var_epoch_ret_search(re,2) = mean(ret_search_sqr_Desk(eloc,:,re),'all');
    end
    
    for re = 1:size(ret_all_sqr_MoBI,3) % loop over retrieval_all trials
        var_epoch_ret_all(re,1) = mean(ret_all_sqr_MoBI(eloc,:,re),'all');
        var_epoch_ret_all(re,2) = mean(ret_all_sqr_Desk(eloc,:,re),'all');
    end    
    
    
end
  