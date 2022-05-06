function [search_duration_all,search_duration_2_3,positions,distance_error] = WM_06_behavioral(EEG)

    % 1. 
    % add event codes that indicates the trial number of search trials
    % find target distance and target angle
    
    
    targetDistances = [];
    targetAngles = [];
    
    % find trial start and end indices
    searchTrialStarts   = find(contains({EEG.event(:).type},'searchtrial:start'));
    searchTrialFounds   = find(contains({EEG.event(:).type},'searchtrial:found'));
    
       
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
            
            % find the target angle and distance
            if session_idx == 1
                targetAngles(block_idx) = str2double(extractBetween(EEG.event(blockStart_idx).type,'target_angle:',';target_distance'));
                targetDistances(block_idx) = str2double(extractBetween(EEG.event(blockStart_idx).type,'target_distance:',';'));
            else
                targetAngles(block_idx+6) = str2double(extractBetween(EEG.event(blockStart_idx).type,'target_angle:',';target_distance'));
                targetDistances(block_idx+6) = str2double(extractBetween(EEG.event(blockStart_idx).type,'target_distance:',';'));
            end    
            
            
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
            end
        
        end              
    end
            

    % 2.
    % calculate search durations

    % find search start and found latencies in the session
    search_start_all = [];
    search_found_all = [];
    search_start_2_3 = [];
    search_found_2_3 = [];
        
    a = 1;
    b = 1;
    % iterate over all events
    for i = 1:numel(EEG.event(:))
        if contains({EEG.event(i).type}, 'searchtrial:start') == 1 
            search_start_all(a) = (EEG.event(i).latency)*4/1000;
            a = a + 1;
        elseif contains({EEG.event(i).type}, 'searchtrial:found') == 1 
            search_found_all(b) = (EEG.event(i).latency)*4/1000;
            b = b + 1;
        end
    end
    
    % subtract the start latencies from found latencies
    search_duration_all = (search_found_all - search_start_all)';
    
    
    c = 1;
    d = 1;
    % iterate over all events
    for i = 1:numel(EEG.event(:))
        if contains({EEG.event(i).type}, 'searchtrial:start') == 1 && EEG.event(i).order ~= 1
            search_start_2_3(c) = (EEG.event(i).latency)*4/1000;
            c = c + 1;
        elseif contains({EEG.event(i).type}, 'searchtrial:found') == 1 && EEG.event(i).order ~= 1
            search_found_2_3(d) = (EEG.event(i).latency)*4/1000;
            d = d + 1;
        end
    end
    
    search_duration_2_3 = (search_found_2_3 - search_start_2_3)';
    
    
    % 3.
    % calculate distance error and create a matrice that includes positions
    
    targetPos_x = [];
    targetPos_y = [];
    
    response_x = [];
    response_y = [];
    
    distance_error = [];
    
    % 1.row = target_x, 2.row = target_y, 3.row = response_x,, 4.row = response_y
    positions = []; 
    
    % loop over blocks, find x and y positions
    for i = 1:12
        [targetPos_x(i),targetPos_y(i)] = pol2cart(deg2rad(-targetAngles(i)),targetDistances(i));
    end
    
    % create target position matricies at the same number of guess trials   
 
    targetPos_x = [repelem(targetPos_x(1),4),repelem(targetPos_x(2),4),repelem(targetPos_x(3),4),repelem(targetPos_x(4),4),...
        repelem(targetPos_x(5),4),repelem(targetPos_x(6),4),repelem(targetPos_x(7),4),repelem(targetPos_x(8),4),repelem(targetPos_x(9),4)...
        repelem(targetPos_x(10),4),repelem(targetPos_x(11),4),repelem(targetPos_x(12),4)];
    
    targetPos_y = [repelem(targetPos_y(1),4),repelem(targetPos_y(2),4),repelem(targetPos_y(3),4),repelem(targetPos_y(4),4),...
        repelem(targetPos_y(5),4),repelem(targetPos_y(6),4),repelem(targetPos_y(7),4),repelem(targetPos_y(8),4),repelem(targetPos_y(9),4)...
        repelem(targetPos_y(10),4),repelem(targetPos_y(11),4),repelem(targetPos_y(12),4)];
    
    
    % find response x and y positions
   
    c = 1;  
    for i = 1:numel(EEG.event(:))
        if contains({EEG.event(i).type}, 'guesstrial:keypress') == 1
            response_x(c) = str2double(extractBetween(EEG.event(i).type,'response_x:',';response_y'));
            response_y(c) = str2double(extractBetween(EEG.event(i).type,'response_y:',';'));
            c = c + 1;
        end
    end
    
    % fill the position matrix
    positions = [(targetPos_x)',(targetPos_y)',(response_x)',(response_y)'];
    
    
    % calculate distance errors
    
    for i = 1:48 
        distance_error(i) = sqrt((targetPos_x(i)-response_x(i))^2 + (targetPos_y(i)-response_y(i))^2);
    end
    
    distance_error = (distance_error)';

end