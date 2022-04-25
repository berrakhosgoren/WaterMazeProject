function [epochedEEG, epochedEEG_baseline] = WM_03_epoch(bandpassedEEG)
% generates 4 second epochs from segments 

% encoding: -2, +2 sec: searchtrial:found
% retrieval: -2, +2 sec: guesstrial:start
% baseline: 0, +4 sec: segments of continuous baseline period

    EEG = bandpassedEEG;
    
    % find trial start and end indices
    searchTrialStarts   = find(contains({EEG.event(:).type},'searchtrial:start'));
    searchTrialEnds     = find(contains({EEG.event(:).type},'searchtrial:end'));
    searchTrialFounds   = find(contains({EEG.event(:).type},'searchtrial:found'));
    guessTrialStarts    = find(contains({EEG.event(:).type},'guesstrial:start'));
    guessTrialEnds      = find(contains({EEG.event(:).type},'guesstrial:end'));  
    
    nSearch = 3;
    nGuess  = 4;


    % First: check whether block and trial numbers are correct
    %-----------------------------------------------------------------------

    % seperate the data into VR and Desktop sessions
    for session_idx = 1:2 
        
        % iterate over blocks
        for block_idx = 1:6 % there are 6 blocks in each session
            
            % find events by their block indices
            blockStartIndices   = find(contains({EEG.event(:).type},['block:start;block_index:' num2str(block_idx) ';']));
            blockEndIndices     = find(contains({EEG.event(:).type},['block:end;block_index:' num2str(block_idx)]));
            
            % choose the block that is in the session
            blockStart_idx = blockStartIndices(session_idx);
            blockEnd_idx   = blockEndIndices(session_idx);
            
            % check the order of block indices
            if blockEnd_idx <= blockStart_idx
                error(['Events marking block ' num2str(b) ' are invalid'])
            end   
            
            % choose search trials in the block
            searchStartsInBlock  = find(searchTrialStarts(:) > blockStart_idx & searchTrialStarts(:) < blockEnd_idx);
            searchEndsInBlock    = find(searchTrialEnds(:) < blockEnd_idx & searchTrialEnds(:) > blockStart_idx);
            
            % choose guess trials in the block
            guessStartsInBlock  = find(guessTrialStarts(:) > blockStart_idx & guessTrialStarts(:) < blockEnd_idx);
            guessEndsInBlock    = find(guessTrialEnds(:) < blockEnd_idx & guessTrialEnds(:) > blockStart_idx);
                            
            % check if the order and number of trials are correct
            if numel(searchStartsInBlock) ~= nSearch || numel(searchStartsInBlock) ~= numel(searchEndsInBlock)   
                error(['Invalid number of search trials in block ' num2str(block_idx)])
            elseif numel(guessStartsInBlock) ~= nGuess || numel(guessStartsInBlock) ~= numel(guessEndsInBlock)     
                error(['Invalid number of guess trials in block ' num2str(block_idx)])
            end
                           
        end     
    end    

    
       
    % Second: add event codes
    %-----------------------------------------------------------------------------
       
    
    % loop over sessions
    for session_idx = 1:2
        
        % iterate over blocks
        for block_idx = 1:6 % there are 6 blocks in each session
            
            %---------------------------------------------------------
            % add new information to the event codes: search/guess_index,
            % block_index, session_index etc.
            
            % find events by their block indices
            blockStartIndices   = find(contains({EEG.event(:).type},['block:start;block_index:' num2str(block_idx) ';']));
            blockEndIndices     = find(contains({EEG.event(:).type},['block:end;block_index:' num2str(block_idx)]));
            
            % choose the block that is in the session
            blockStart_idx = blockStartIndices(session_idx);
            blockEnd_idx   = blockEndIndices(session_idx);    
            
            % find the origin angle of the block
            block_angle = str2double(extractBetween(EEG.event(blockStart_idx).type,'origin_angle:',';target_angle'));
                  
            % choose search trial found in the block           
            searchFoundInBlock = [];
            sF_count = 1;
            
            for searchFnumber = 1:36               
               if searchTrialFounds(searchFnumber) > blockStart_idx && searchTrialFounds(searchFnumber) < blockEnd_idx
                    searchFoundInBlock(sF_count) = searchTrialFounds(searchFnumber);
                    sF_count = sF_count + 1; 
               end                                
            end
            
            for search_idx = 1:3
                % add new event information
                EEG.event(searchFoundInBlock(search_idx)).order = search_idx;
                EEG.event(searchFoundInBlock(search_idx)).block = block_idx;
                EEG.event(searchFoundInBlock(search_idx)).rotation = 0;
                EEG.event(searchFoundInBlock(search_idx)).session = session_idx;
                
            end
            
            
            % choose search trial start in the block
            searchStartInBlock = [];
            sS_count = 1;
            
            for searchSnumber = 1:36               
               if searchTrialStarts(searchSnumber) > blockStart_idx && searchTrialStarts(searchSnumber) < blockEnd_idx
                    searchStartInBlock(sS_count) = searchTrialStarts(searchSnumber);
                    sS_count = sS_count + 1; 
               end                                
            end
            
            for search_idx = 1:3
                % add new event information
                EEG.event(searchStartInBlock(search_idx)).order = search_idx;
                EEG.event(searchStartInBlock(search_idx)).block = block_idx;
                EEG.event(searchStartInBlock(search_idx)).rotation = 0;
                EEG.event(searchStartInBlock(search_idx)).session = session_idx;
                
            end
            
            
            % choose guess trials in the block
            guessStartInBlock = [];
            g_count = 1;
            
            for guessnumber = 1:48               
               if guessTrialStarts(guessnumber) > blockStart_idx && guessTrialStarts(guessnumber) < blockEnd_idx
                    guessStartInBlock(g_count) = guessTrialStarts(guessnumber);
                    g_count = g_count + 1; 
               end                                
            end
            
            for guess_idx = 1:4
                % add new event information
                EEG.event(guessStartInBlock(guess_idx)).order = guess_idx;
                EEG.event(guessStartInBlock(guess_idx)).block = block_idx;
                EEG.event(guessStartInBlock(guess_idx)).session = session_idx;
                               
                % find the angle of the guess trial
                guess_angle = str2double(extractBetween(EEG.event(guessStartInBlock(guess_idx)).type,'starting_angle:',';'));
                rotation = block_angle - guess_angle;
                EEG.event(guessStartInBlock(guess_idx)).rotation = mod(rotation,360);
                
            end
        
        end              
    end
            
    
    % Third: extract epochs from trials
    %-----------------------------------------------------------------------------
    
    % guess_epochs include all the events that start with guesstrial:start
    guess_epochs = [];
    search_epochs = [];
    guess.count  = 1;
    search.count = 1;

    for event_idx = 1:length(EEG.event)
   
        if startsWith(EEG.event(event_idx).type, 'searchtrial:found') == 1
            search_epochs{search.count} = EEG.event(event_idx).type;
            search.count = search.count + 1;
        end  
              
        if startsWith(EEG.event(event_idx).type, 'guesstrial:start') == 1
            guess_epochs{guess.count} = EEG.event(event_idx).type;
            guess.count = guess.count + 1;
        end   
       
        
    end
    
    % segments data into 2 second epochs (searchtrial:found, guesstrial:start) 
    epochedEEG = pop_epoch(EEG, ['searchtrial:start',search_epochs, guess_epochs], [-2 2], 'epochinfo', 'yes');
    

    
    % Fourth: extract baseline epochs
    %-------------------------------------------------------------------------------
    
    % find baseline start and end indices
    baseline_starts = find(contains({EEG.event(:).type},'baseline:start'));
    baseline_ends   = find(contains({EEG.event(:).type},'baseline:end'));
    
    % seperate the data into VR and Desktop sessions
    for session_idx = 1:2 % 1:MoBI 2:Desktop
        
        % find the first block starts indicies
        block_starts = find(contains({EEG.event(:).type},('block:start;block_index:1;')));
        % choose the one in the session
        block_start_idx = block_starts(session_idx);
        
        % choose all baselines before the start of the first block
        % (baselines in the session)
        baseline_startsInSession = [];
        baseline_endsInSession   = [];
        start_count = 1;
        end_count   = 1;
        
        for start_number = 1:numel(baseline_starts)
            if baseline_starts(start_number) < block_start_idx
                baseline_startsInSession(start_count) = baseline_starts(start_number);
                start_count = start_count + 1;
            end
        end
        
        for end_number = 1:numel(baseline_ends)
            if baseline_ends(end_number) < block_start_idx
                baseline_endsInSession(end_count) = baseline_ends(end_number);
                end_count = end_count + 1;
            end    
        end
        
        % select the correct baseline window (right before the block start)
        if session_idx == 1
            baselineStart_MoBI  = EEG.event(max(baseline_startsInSession)).latency;
            baselineEnd_MoBI    = EEG.event(max(baseline_endsInSession)).latency;
        else
            baselineStart_Desktop = EEG.event(max(baseline_startsInSession)).latency;
            baselineEnd_Desktop   = EEG.event(max(baseline_endsInSession)).latency;
        end
               
    end
    
    % add dummy events 'X' that reoccure in 4 seconds to the baseline period 
    % since the data is sampled at 250 Hz
    % to translate the latency to second: latency * 4/1000
    latency_M = baselineStart_MoBI;
    latency_D = baselineStart_Desktop; 
    for i = 1:round((baselineEnd_MoBI - baselineStart_MoBI)*4/4000, 0)
        
        n_events = length(EEG.event);  
        
        EEG.event(n_events+1).type = 'X1';
        EEG.event(n_events+1).latency = latency_M;
        EEG.event(n_events+1).urevent = n_events + 1;
        EEG.event(n_events+1).session = 1;
        
        latency_M = latency_M + (4*250);
        
    end
    
    for i = 1:round((baselineEnd_Desktop - baselineStart_Desktop)*4/4000, 0)
        
        n_events = length(EEG.event);  
        
        EEG.event(n_events+1).type = 'X2';
        EEG.event(n_events+1).latency = latency_D;
        EEG.event(n_events+1).urevent = n_events + 1;
        EEG.event(n_events+1).session = 2;
        
        latency_D = latency_D + (4*250);
        
    end
    
    
    % check for consistency and reorder the events chronologically
    EEG = eeg_checkset(EEG,'eventconsistency');
    
    % segment the baseline into 2 seconds epochs 
    epochedEEG_baseline = pop_epoch(EEG, {'X1','X2'}, [0 4], 'epochinfo', 'yes');
    

end