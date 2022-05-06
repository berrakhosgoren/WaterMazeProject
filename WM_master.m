% initialize EEGLAB

eeglab

% initialize fieldtrip
ft_defaults

if strcmp(pwd, 'P:\Berrak_Hosgoren\WM_analysis_channel_level')
    projectPath = 'P:\Berrak_Hosgoren';
else
    projectPath = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject';
end


% participant IDs for each loop 
participantsPreproc     = [81001:81004, 81006:81011, 82001:82004, 82006:82008, 84009, 82011 83001:83003, 83006:83011];

% configuration
WM_config; 

force_recompute = 0;

%% STEP 01: Import files

% WM_01_import.m


%% STEP 02: Preprocessing %%

% loop over participants

for Pi = 1:numel(participantsPreproc)
    
    subject = participantsPreproc(Pi);
    participantFolder = fullfile(bemobil_config.study_folder, bemobil_config.raw_EEGLAB_data_folder, [num2str(subject)]);
    
    % Trim files
    %--------------------------------------------------------------------------------------------------------------------------
    
    rawFileNameEEG          = [num2str(subject') '_merged_EEG.set'];
    trimmedFileNameEEG      = [num2str(subject) '_merged_EEG_trimmed.set'];
    
    if ~exist(fullfile(participantFolder, trimmedFileNameEEG), 'file')
        
        rawEEG       = pop_loadset('filepath', participantFolder ,'filename', rawFileNameEEG);
        [trimmedEEG] = WM_02_trim(rawEEG);
        pop_saveset(trimmedEEG, 'filepath', participantFolder ,'filename', trimmedFileNameEEG)
        
    else
        trimmedEEG =  pop_loadset('filepath', participantFolder ,'filename', trimmedFileNameEEG);
    end
    

    % Preprocess Data 
    %--------------------------------------------------------------------------------------------------------------------------
    
    % prepare filepaths and check if already done
	disp(['Subject #' num2str(subject)]);
    
	STUDY = []; CURRENTSTUDY = 0; ALLEEG = [];  CURRENTSET=[]; EEG=[]; EEG_interp_avref = []; EEG_single_subject_final = [];
	
	input_filepath = [bemobil_config.study_folder bemobil_config.raw_EEGLAB_data_folder bemobil_config.filename_prefix num2str(subject)];
	output_filepath = [bemobil_config.study_folder bemobil_config.single_subject_analysis_folder bemobil_config.filename_prefix num2str(subject)];
	
	try
		% load completely processed file
		EEG_single_subject_final = pop_loadset('filename', [ bemobil_config.filename_prefix num2str(subject)...
			'_' bemobil_config.single_subject_cleaned_ICA_filename], 'filepath', output_filepath);
    catch
        disp('...failed. Computing now.')
    end
	
    
	if ~force_recompute && exist('EEG_single_subject_final','var') && ~isempty(EEG_single_subject_final)
		clear EEG_single_subject_final
		disp('Subject is completely preprocessed already.')
		continue  
    end
	
	% load data that is provided by the BIDS importer
    % make sure the data is stored in double precision, large datafiles are supported, and no memory mapped objects are
    % used but data is processed locally
	
    try 
        pop_editoptions( 'option_saveversion6', 0, 'option_single', 0, 'option_memmapdata', 0);
    catch
        warning('Could NOT edit EEGLAB memory options!!'); 
    end
    
    % load files that were created from xdf to BIDS to EEGLAB
    EEG = trimmedEEG;

    % processing wrappers for basic processing and AMICA
    
    % do basic preprocessing, line noise removal, and channel interpolation
	[ALLEEG, EEG_preprocessed, CURRENTSET] = bemobil_process_all_EEG_preprocessing(subject, bemobil_config, ALLEEG, EEG, CURRENTSET, force_recompute);
    
    % start the processing pipeline for AMICA
	bemobil_process_all_AMICA(ALLEEG, EEG_preprocessed, CURRENTSET, subject, bemobil_config, force_recompute);
    
    
end

subject

disp('PROCESSING DONE! YOU CAN CLOSE THE WINDOW NOW!')


%% STEP 02.1: Bandpass Filter
%---------------------------------------------------------------------------

% pass this step if you calculate ERSP

% Apply bandpass filter

% loop over participants
for Pi = 1:numel(participantsPreproc)
    
    STUDY = []; CURRENTSTUDY = 0; ALLEEG = [];  CURRENTSET=[]; EEG = [];
    
    subject                 = participantsPreproc(Pi);
    participantFolder       = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    preprocessedFileNameEEG = [num2str(subject') '_cleaned_with_ICA.set']; 
    
    
    EEG = pop_loadset('filepath', participantFolder ,'filename', preprocessedFileNameEEG);  
    
    lowerPassbandEdge  = 4;
    higherPassbandEdge = 8;
 
    out_filename = [num2str(subject') '_bandpass_filtered.set'];
    out_filepath = [bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]];
    
    [ ALLEEG, EEG, CURRENTSET ] = bemobil_filter(ALLEEG, EEG, CURRENTSET, lowerPassbandEdge, higherPassbandEdge,...
    out_filename, out_filepath);


end

%% STEP 03: Extract epochs


% loop over participants
for Pi = 1:numel(participantsPreproc)
   
    subject = participantsPreproc(Pi);
    participantFolder = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    
    bandpassedFileNameEEG      = [num2str(subject') '_bandpass_filtered.set'];
    %preprocessedFileNameEEG    = [num2str(subject') '_cleaned_with_ICA.set'];
    epochedFileNameEEG         = [num2str(subject') '_epoched.set'];
    epochedBaselineFileNameEEG = [num2str(subject') '_epoched_baseline.set'];
    
    
    if ~exist(fullfile(participantFolder, epochedFileNameEEG), 'file') && ~exist(fullfile(participantFolder, epochedBaselineFileNameEEG), 'file')
        
        preprocessedEEG =  pop_loadset('filepath', participantFolder ,'filename', bandpassedFileNameEEG);        
        [epochedEEG, epochedEEG_baseline] = WM_03_epoch(preprocessedEEG);       
        pop_saveset(epochedEEG, 'filepath', participantFolder ,'filename', epochedFileNameEEG)
        pop_saveset(epochedEEG_baseline, 'filepath', participantFolder ,'filename', epochedBaselineFileNameEEG)
        
    else
        epochedEEG          =  pop_loadset('filepath', participantFolder ,'filename', epochedFileNameEEG);
        epochedEEG_baseline =  pop_loadset('filepath', participantFolder ,'filename', epochedBaselineFileNameEEG);
    end
      
end    



%% ---ERSP--- 

% pass this step for ERD/ERS calculations

for Pi = 1:numel(participantsPreproc)
    
    subject = participantsPreproc(Pi);
    input_path     = [bemobil_config.study_folder bemobil_config.single_subject_analysis_folder];
    input_filename = [num2str(subject') '_epoched_withoutbandpass.set'];
    channels_to_use_for_study = 1:128;
    output_foldername = '';
    timewarp_latency_loadpath = NaN;
    epochs_info_filename_input = NaN;
    epochs_info_filename_output = NaN;
    recompute = true;
    has_timewarp_latencies = false;
    dont_warp_but_cut = false;
    n_freqs = 10;
    n_times = 250;


    bemobil_compute_single_trial_ERSPs_channels(input_path , input_filename,  subject, channels_to_use_for_study,...
      output_foldername, timewarp_latency_loadpath, epochs_info_filename_input, epochs_info_filename_output, recompute,...
      0,dont_warp_but_cut, n_freqs, n_times )

end

%% STEP 04.1: ERD Calculation / Main 
% create theta matricies and tables that includes all participants
% encoding/retrieval/baseline intertrial variance
% ERD/ERS

% seperate patient and control participants
patients = [];
controls = [];
count_p = 1; % patients count
count_c = 1; % controls count

% 1. Create matricies that includes each electrodes separetely
%----------------------------------------------------------------

% loop over participants
for Pi = 1:numel(participantsPreproc)
    
    subject                    = participantsPreproc(Pi);
    participantFolder          = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    epochedFileNameEEG         = [num2str(subject') '_epoched.set'];
    epochedBaselineFileNameEEG = [num2str(subject') '_epoched_baseline.set'];
    epochedEEG                 =  pop_loadset('filepath', participantFolder ,'filename', epochedFileNameEEG);
    epochedEEG_baseline        =  pop_loadset('filepath', participantFolder ,'filename', epochedBaselineFileNameEEG);

    
    % create different matricies for patients and controls
    if contains(num2str(subject), '81') == 1
     
        [variance_fm, variance_allEloc, erd_fm, erd_allEloc, var_epoch_enc_all, var_epoch_enc_2_3, var_epoch_ret_guess, var_epoch_ret_all] = WM_04_ERD1_main(epochedEEG,epochedEEG_baseline);
        
        varEnMobi_all_fm_pat(:,:,count_p)  = variance_fm(:,:,1);
        varEnDesk_all_fm_pat(:,:,count_p)  = variance_fm(:,:,2);
        varEnMobi_2_3_fm_pat(:,:,count_p)  = variance_fm(:,:,3);
        varEnDesk_2_3_fm_pat(:,:,count_p)  = variance_fm(:,:,4);
        
        varRetMobi_guess_fm_pat(:,:,count_p) = variance_fm(:,:,5);
        varRetDesk_guess_fm_pat(:,:,count_p) = variance_fm(:,:,6);
        varRetMobi_all_fm_pat(:,:,count_p)   = variance_fm(:,:,7);
        varRetDesk_all_fm_pat(:,:,count_p)   = variance_fm(:,:,8);
        
        varBasMobi_fm_pat(:,:,count_p) = variance_fm(:,:,9);
        varBasDesk_fm_pat(:,:,count_p) = variance_fm(:,:,10);
        
        
        varEnMobi_all_allEloc_pat(:,:,count_p)  = variance_allEloc(:,:,1);
        varEnDesk_all_allEloc_pat(:,:,count_p)  = variance_allEloc(:,:,2);
        varEnMobi_2_3_allEloc_pat(:,:,count_p)  = variance_allEloc(:,:,3);
        varEnDesk_2_3_allEloc_pat(:,:,count_p)  = variance_allEloc(:,:,4);
        
        varRetMobi_guess_allEloc_pat(:,:,count_p) = variance_allEloc(:,:,5);
        varRetDesk_guess_allEloc_pat(:,:,count_p) = variance_allEloc(:,:,6);
        varRetMobi_all_allEloc_pat(:,:,count_p)   = variance_allEloc(:,:,7);
        varRetDesk_all_allEloc_pat(:,:,count_p)   = variance_allEloc(:,:,8);
        
        varBasMobi_allEloc_pat(:,:,count_p) = variance_allEloc(:,:,9);
        varBasDesk_allEloc_pat(:,:,count_p) = variance_allEloc(:,:,10);
        
        
        erdEnMobi_all_fm_pat(:,:,count_p)    = erd_fm(:,:,1);
        erdEnDesk_all_fm_pat(:,:,count_p)    = erd_fm(:,:,2);
        erdEnMobi_2_3_fm_pat(:,:,count_p)    = erd_fm(:,:,3);
        erdEnDesk_2_3_fm_pat(:,:,count_p)    = erd_fm(:,:,4);
        erdRetMobi_guess_fm_pat(:,:,count_p) = erd_fm(:,:,5);
        erdRetDesk_guess_fm_pat(:,:,count_p) = erd_fm(:,:,6);
        erdRetMobi_all_fm_pat(:,:,count_p)   = erd_fm(:,:,7);
        erdRetDesk_all_fm_pat(:,:,count_p)   = erd_fm(:,:,8);
        
        erdEnMobi_all_allEloc_pat(:,:,count_p)    = erd_allEloc(:,:,1);
        erdEnDesk_all_allEloc_pat(:,:,count_p)    = erd_allEloc(:,:,2);
        erdEnMobi_2_3_allEloc_pat(:,:,count_p)    = erd_allEloc(:,:,3);
        erdEnDesk_2_3_allEloc_pat(:,:,count_p)    = erd_allEloc(:,:,4);
        erdRetMobi_guess_allEloc_pat(:,:,count_p) = erd_allEloc(:,:,5);
        erdRetDesk_guess_allEloc_pat(:,:,count_p) = erd_allEloc(:,:,6);
        erdRetMobi_all_allEloc_pat(:,:,count_p)   = erd_allEloc(:,:,7);
        erdRetDesk_all_allEloc_pat(:,:,count_p)   = erd_allEloc(:,:,8);
       
        varEpoch_enc_all_Mobi_p(:,count_p) = var_epoch_enc_all(:,1);
        varEpoch_enc_all_Desk_p(:,count_p) = var_epoch_enc_all(:,2);
        varEpoch_enc_2_3_Mobi_p(:,count_p) = var_epoch_enc_2_3(:,1);
        varEpoch_enc_2_3_Desk_p(:,count_p) = var_epoch_enc_2_3(:,2);
        
        varEpoch_ret_guess_Mobi_p(:,count_p) = var_epoch_ret_guess(:,1);
        varEpoch_ret_guess_Desk_p(:,count_p) = var_epoch_ret_guess(:,2);
        varEpoch_ret_all_Mobi_p(:,count_p)   = var_epoch_ret_all(:,1);
        varEpoch_ret_all_Desk_p(:,count_p)   = var_epoch_ret_all(:,2);
        
        patients(count_p) = subject;
        count_p = count_p + 1;
        
    else
        
        [variance_fm, variance_allEloc, erd_fm, erd_allEloc, var_epoch_enc_all, var_epoch_enc_2_3, var_epoch_ret_guess, var_epoch_ret_all] = WM_04_ERD1_main(epochedEEG,epochedEEG_baseline);
        
        varEnMobi_all_fm_cont(:,:,count_c)  = variance_fm(:,:,1);
        varEnDesk_all_fm_cont(:,:,count_c)  = variance_fm(:,:,2);
        varEnMobi_2_3_fm_cont(:,:,count_c)  = variance_fm(:,:,3);
        varEnDesk_2_3_fm_cont(:,:,count_c)  = variance_fm(:,:,4);
        
        varRetMobi_guess_fm_cont(:,:,count_c) = variance_fm(:,:,5);
        varRetDesk_guess_fm_cont(:,:,count_c) = variance_fm(:,:,6);
        varRetMobi_all_fm_cont(:,:,count_c)   = variance_fm(:,:,7);
        varRetDesk_all_fm_cont(:,:,count_c)   = variance_fm(:,:,8);
        
        varBasMobi_fm_cont(:,:,count_c) = variance_fm(:,:,9);
        varBasDesk_fm_cont(:,:,count_c) = variance_fm(:,:,10);
        
        
        varEnMobi_all_allEloc_cont(:,:,count_c)  = variance_allEloc(:,:,1);
        varEnDesk_all_allEloc_cont(:,:,count_c)  = variance_allEloc(:,:,2);
        varEnMobi_2_3_allEloc_cont(:,:,count_c)  = variance_allEloc(:,:,3);
        varEnDesk_2_3_allEloc_cont(:,:,count_c)  = variance_allEloc(:,:,4);
        
        varRetMobi_guess_allEloc_cont(:,:,count_c) = variance_allEloc(:,:,5);
        varRetDesk_guess_allEloc_cont(:,:,count_c) = variance_allEloc(:,:,6);
        varRetMobi_all_allEloc_cont(:,:,count_c)   = variance_allEloc(:,:,7);
        varRetDesk_all_allEloc_cont(:,:,count_c)   = variance_allEloc(:,:,8);
        
        varBasMobi_allEloc_cont(:,:,count_c) = variance_allEloc(:,:,9);
        varBasDesk_allEloc_cont(:,:,count_c) = variance_allEloc(:,:,10);
        
        
        erdEnMobi_all_fm_cont(:,:,count_c)    = erd_fm(:,:,1);
        erdEnDesk_all_fm_cont(:,:,count_c)    = erd_fm(:,:,2);
        erdEnMobi_2_3_fm_cont(:,:,count_c)    = erd_fm(:,:,3);
        erdEnDesk_2_3_fm_cont(:,:,count_c)    = erd_fm(:,:,4);
        erdRetMobi_guess_fm_cont(:,:,count_c) = erd_fm(:,:,5);
        erdRetDesk_guess_fm_cont(:,:,count_c) = erd_fm(:,:,6);
        erdRetMobi_all_fm_cont(:,:,count_c)   = erd_fm(:,:,7);
        erdRetDesk_all_fm_cont(:,:,count_c)   = erd_fm(:,:,8);
        
        erdEnMobi_all_allEloc_cont(:,:,count_c)    = erd_allEloc(:,:,1);
        erdEnDesk_all_allEloc_cont(:,:,count_c)    = erd_allEloc(:,:,2);
        erdEnMobi_2_3_allEloc_cont(:,:,count_c)    = erd_allEloc(:,:,3);
        erdEnDesk_2_3_allEloc_cont(:,:,count_c)    = erd_allEloc(:,:,4);
        erdRetMobi_guess_allEloc_cont(:,:,count_c) = erd_allEloc(:,:,5);
        erdRetDesk_guess_allEloc_cont(:,:,count_c) = erd_allEloc(:,:,6);
        erdRetMobi_all_allEloc_cont(:,:,count_c)   = erd_allEloc(:,:,7);
        erdRetDesk_all_allEloc_cont(:,:,count_c)   = erd_allEloc(:,:,8);
       
        varEpoch_enc_all_Mobi_c(:,count_c) = var_epoch_enc_all(:,1);
        varEpoch_enc_all_Desk_c(:,count_c) = var_epoch_enc_all(:,2);
        varEpoch_enc_2_3_Mobi_c(:,count_c) = var_epoch_enc_2_3(:,1);
        varEpoch_enc_2_3_Desk_c(:,count_c) = var_epoch_enc_2_3(:,2);
        
        varEpoch_ret_guess_Mobi_c(:,count_c) = var_epoch_ret_guess(:,1);
        varEpoch_ret_guess_Desk_c(:,count_c) = var_epoch_ret_guess(:,2);
        varEpoch_ret_all_Mobi_c(:,count_c)   = var_epoch_ret_all(:,1);
        varEpoch_ret_all_Desk_c(:,count_c)   = var_epoch_ret_all(:,2);
        
        
        controls(count_c) = subject;  
        count_c = count_c + 1;
        
    end    
          
end


% save the matricies
% 3D matricies: 
% First dimension: electrodes
% Second dimension: data points
% Third dimension: participants

table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\IntertrialVariance';

save(fullfile(table_path,'varEnMobi_all_fm_pat.mat'), 'varEnMobi_all_fm_pat');
save(fullfile(table_path,'varEnMobi_all_fm_cont.mat'), 'varEnMobi_all_fm_cont');
save(fullfile(table_path,'varEnMobi_2_3_fm_pat.mat'), 'varEnMobi_2_3_fm_pat');
save(fullfile(table_path,'varEnMobi_2_3_fm_cont.mat'), 'varEnMobi_2_3_fm_cont');
save(fullfile(table_path,'varEnDesk_all_fm_pat.mat'), 'varEnDesk_all_fm_pat');
save(fullfile(table_path,'varEnDesk_all_fm_cont.mat'), 'varEnDesk_all_fm_cont');
save(fullfile(table_path,'varEnDesk_2_3_fm_pat.mat'), 'varEnDesk_2_3_fm_pat');
save(fullfile(table_path,'varEnDesk_2_3_fm_cont.mat'), 'varEnDesk_2_3_fm_cont');
save(fullfile(table_path,'varRetMobi_guess_fm_pat.mat'), 'varRetMobi_guess_fm_pat');
save(fullfile(table_path,'varRetMobi_guess_fm_cont.mat'), 'varRetMobi_guess_fm_cont');
save(fullfile(table_path,'varRetMobi_all_fm_pat.mat'), 'varRetMobi_all_fm_pat');
save(fullfile(table_path,'varRetMobi_all_fm_cont.mat'), 'varRetMobi_all_fm_cont');
save(fullfile(table_path,'varRetDesk_guess_fm_pat.mat'), 'varRetDesk_guess_fm_pat');
save(fullfile(table_path,'varRetDesk_guess_fm_cont.mat'), 'varRetDesk_guess_fm_cont');
save(fullfile(table_path,'varRetDesk_all_fm_pat.mat'), 'varRetDesk_all_fm_pat');
save(fullfile(table_path,'varRetDesk_all_fm_cont.mat'), 'varRetDesk_all_fm_cont');
save(fullfile(table_path,'varBasMobi_fm_pat.mat'), 'varBasMobi_fm_pat');
save(fullfile(table_path,'varBasMobi_fm_cont.mat'), 'varBasMobi_fm_cont');
save(fullfile(table_path,'varBasDesk_fm_pat.mat'), 'varBasDesk_fm_pat');
save(fullfile(table_path,'varBasDesk_fm_cont.mat'), 'varBasDesk_fm_cont');

save(fullfile(table_path,'varEnMobi_all_allEloc_pat.mat'), 'varEnMobi_all_allEloc_pat');
save(fullfile(table_path,'varEnMobi_all_allEloc_cont.mat'), 'varEnMobi_all_allEloc_cont');
save(fullfile(table_path,'varEnMobi_2_3_allEloc_pat.mat'), 'varEnMobi_2_3_allEloc_pat');
save(fullfile(table_path,'varEnMobi_2_3_allEloc_cont.mat'), 'varEnMobi_2_3_allEloc_cont');
save(fullfile(table_path,'varEnDesk_all_allEloc_pat.mat'), 'varEnDesk_all_allEloc_pat');
save(fullfile(table_path,'varEnDesk_all_allEloc_cont.mat'), 'varEnDesk_all_allEloc_cont');
save(fullfile(table_path,'varEnDesk_2_3_allEloc_pat.mat'), 'varEnDesk_all_allEloc_pat');
save(fullfile(table_path,'varEnDesk_2_3_allEloc_cont.mat'), 'varEnDesk_2_3_allEloc_cont');
save(fullfile(table_path,'varRetMobi_guess_allEloc_pat.mat'), 'varRetMobi_guess_allEloc_pat');
save(fullfile(table_path,'varRetMobi_guess_allEloc_cont.mat'), 'varRetMobi_guess_allEloc_cont');
save(fullfile(table_path,'varRetMobi_all_allEloc_pat.mat'), 'varRetMobi_all_allEloc_pat');
save(fullfile(table_path,'varRetMobi_all_allEloc_cont.mat'), 'varRetMobi_all_allEloc_cont');
save(fullfile(table_path,'varRetDesk_guess_allEloc_pat.mat'), 'varRetDesk_guess_allEloc_pat');
save(fullfile(table_path,'varRetDesk_guess_allEloc_cont.mat'), 'varRetDesk_guess_allEloc_cont');
save(fullfile(table_path,'varRetDesk_all_allEloc_pat.mat'), 'varRetDesk_all_allEloc_pat');
save(fullfile(table_path,'varRetDesk_all_allEloc_cont.mat'), 'varRetDesk_all_allEloc_cont');
save(fullfile(table_path,'varBasMobi_allEloc_pat.mat'), 'varBasMobi_allEloc_pat');
save(fullfile(table_path,'varBasMobi_allEloc_cont.mat'), 'varBasMobi_allEloc_cont');
save(fullfile(table_path,'varBasDesk_allEloc_pat.mat'), 'varBasDesk_allEloc_pat');
save(fullfile(table_path,'varBasDesk_allEloc_cont.mat'), 'varBasDesk_allEloc_cont');

table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\ERD';

save(fullfile(table_path,'erdEnMobi_all_fm_pat.mat'), 'erdEnMobi_all_fm_pat');
save(fullfile(table_path,'erdEnMobi_all_fm_cont.mat'), 'erdEnMobi_all_fm_cont');
save(fullfile(table_path,'erdEnMobi_2_3_fm_pat.mat'), 'erdEnMobi_2_3_fm_pat');
save(fullfile(table_path,'erdEnMobi_2_3_fm_cont.mat'), 'erdEnMobi_2_3_fm_cont');
save(fullfile(table_path,'erdEnDesk_all_fm_pat.mat'), 'erdEnDesk_all_fm_pat');
save(fullfile(table_path,'erdEnDesk_all_fm_cont.mat'), 'erdEnDesk_all_fm_cont');
save(fullfile(table_path,'erdEnDesk_2_3_fm_pat.mat'), 'erdEnDesk_2_3_fm_pat');
save(fullfile(table_path,'erdEnDesk_2_3_fm_cont.mat'), 'erdEnDesk_2_3_fm_cont');
save(fullfile(table_path,'erdRetMobi_guess_fm_pat.mat'), 'erdRetMobi_guess_fm_pat');
save(fullfile(table_path,'erdRetMobi_guess_fm_cont.mat'), 'erdRetMobi_guess_fm_cont');
save(fullfile(table_path,'erdRetMobi_all_fm_pat.mat'), 'erdRetMobi_all_fm_pat');
save(fullfile(table_path,'erdRetMobi_all_fm_cont.mat'), 'erdRetMobi_all_fm_cont');
save(fullfile(table_path,'erdRetDesk_guess_fm_pat.mat'), 'erdRetDesk_guess_fm_pat');
save(fullfile(table_path,'erdRetDesk_guess_fm_cont.mat'), 'erdRetDesk_guess_fm_cont');
save(fullfile(table_path,'erdRetDesk_all_fm_pat.mat'), 'erdRetDesk_all_fm_pat');
save(fullfile(table_path,'erdRetDesk_all_fm_cont.mat'), 'erdRetDesk_all_fm_cont');

save(fullfile(table_path,'erdEnMobi_all_allEloc_pat.mat'), 'erdEnMobi_all_allEloc_pat');
save(fullfile(table_path,'erdEnMobi_all_allEloc_cont.mat'), 'erdEnMobi_all_allEloc_cont');
save(fullfile(table_path,'erdEnMobi_2_3_allEloc_pat.mat'), 'erdEnMobi_2_3_allEloc_pat');
save(fullfile(table_path,'erdEnMobi_2_3_allEloc_cont.mat'), 'erdEnMobi_2_3_allEloc_cont');
save(fullfile(table_path,'erdEnDesk_all_allEloc_pat.mat'), 'erdEnDesk_all_allEloc_pat');
save(fullfile(table_path,'erdEnDesk_all_allEloc_cont.mat'), 'erdEnDesk_all_allEloc_cont');
save(fullfile(table_path,'erdEnDesk_2_3_allEloc_pat.mat'), 'erdEnDesk_2_3_allEloc_pat');
save(fullfile(table_path,'erdEnDesk_2_3_allEloc_cont.mat'), 'erdEnDesk_2_3_allEloc_cont');
save(fullfile(table_path,'erdRetMobi_guess_allEloc_pat.mat'), 'erdRetMobi_guess_allEloc_pat');
save(fullfile(table_path,'erdRetMobi_guess_allEloc_cont.mat'), 'erdRetMobi_guess_allEloc_cont');
save(fullfile(table_path,'erdRetMobi_all_allEloc_pat.mat'), 'erdRetMobi_all_allEloc_pat');
save(fullfile(table_path,'erdRetMobi_all_allEloc_cont.mat'), 'erdRetMobi_all_allEloc_cont');
save(fullfile(table_path,'erdRetDesk_guess_allEloc_pat.mat'), 'erdRetDesk_guess_allEloc_pat');
save(fullfile(table_path,'erdRetDesk_guess_allEloc_cont.mat'), 'erdRetDesk_guess_allEloc_cont');
save(fullfile(table_path,'erdRetDesk_all_allEloc_pat.mat'), 'erdRetDesk_all_allEloc_pat');
save(fullfile(table_path,'erdRetDesk_all_allEloc_cont.mat'), 'erdRetDesk_all_allEloc_cont');


% 2. Create theta matricies and tables that includes average of ERD values
% over data points
%---------------------------------------------------------------------------

% loop over patients
for Pi = 1:numel(patients)
    
    meanTime_fm_pat(:,1,Pi) = mean(erdEnMobi_all_fm_pat(:,:,Pi), 2);
    meanTime_fm_pat(:,2,Pi) = mean(erdEnDesk_all_fm_pat(:,:,Pi), 2);
    meanTime_fm_pat(:,3,Pi) = mean(erdEnMobi_2_3_fm_pat(:,:,Pi), 2);
    meanTime_fm_pat(:,4,Pi) = mean(erdEnDesk_2_3_fm_pat(:,:,Pi), 2);
    meanTime_fm_pat(:,5,Pi) = mean(erdRetMobi_guess_fm_pat(:,:,Pi), 2);
    meanTime_fm_pat(:,6,Pi) = mean(erdRetDesk_guess_fm_pat(:,:,Pi), 2);
    meanTime_fm_pat(:,7,Pi) = mean(erdRetMobi_all_fm_pat(:,:,Pi), 2);
    meanTime_fm_pat(:,8,Pi) = mean(erdRetDesk_all_fm_pat(:,:,Pi), 2);
    
    meanTime_allEloc_pat(:,1,Pi) = mean(erdEnMobi_all_allEloc_pat(:,:,Pi), 2);
    meanTime_allEloc_pat(:,2,Pi) = mean(erdEnDesk_all_allEloc_pat(:,:,Pi), 2);
    meanTime_allEloc_pat(:,3,Pi) = mean(erdEnMobi_2_3_allEloc_pat(:,:,Pi), 2);
    meanTime_allEloc_pat(:,4,Pi) = mean(erdEnDesk_2_3_allEloc_pat(:,:,Pi), 2);
    meanTime_allEloc_pat(:,5,Pi) = mean(erdRetMobi_guess_allEloc_pat(:,:,Pi), 2);
    meanTime_allEloc_pat(:,6,Pi) = mean(erdRetDesk_guess_allEloc_pat(:,:,Pi), 2);
    meanTime_allEloc_pat(:,7,Pi) = mean(erdRetMobi_all_allEloc_pat(:,:,Pi), 2);
    meanTime_allEloc_pat(:,8,Pi) = mean(erdRetDesk_all_allEloc_pat(:,:,Pi), 2);
    
    
end    

% loop over controls
for Ci = 1:numel(controls)
    
    meanTime_fm_cont(:,1,Ci) = mean(erdEnMobi_all_fm_cont(:,:,Ci), 2);
    meanTime_fm_cont(:,2,Ci) = mean(erdEnDesk_all_fm_cont(:,:,Ci), 2);
    meanTime_fm_cont(:,3,Ci) = mean(erdEnMobi_2_3_fm_cont(:,:,Ci), 2);
    meanTime_fm_cont(:,4,Ci) = mean(erdEnDesk_2_3_fm_cont(:,:,Ci), 2);
    meanTime_fm_cont(:,5,Ci) = mean(erdRetMobi_guess_fm_cont(:,:,Ci), 2);
    meanTime_fm_cont(:,6,Ci) = mean(erdRetDesk_guess_fm_cont(:,:,Ci), 2);
    meanTime_fm_cont(:,7,Ci) = mean(erdRetMobi_all_fm_cont(:,:,Ci), 2);
    meanTime_fm_cont(:,8,Ci) = mean(erdRetDesk_all_fm_cont(:,:,Ci), 2);
    
    meanTime_allEloc_cont(:,1,Ci) = mean(erdEnMobi_all_allEloc_cont(:,:,Ci), 2);
    meanTime_allEloc_cont(:,2,Ci) = mean(erdEnDesk_all_allEloc_cont(:,:,Ci), 2);
    meanTime_allEloc_cont(:,3,Ci) = mean(erdEnMobi_2_3_allEloc_cont(:,:,Ci), 2);
    meanTime_allEloc_cont(:,4,Ci) = mean(erdEnDesk_2_3_allEloc_cont(:,:,Ci), 2);
    meanTime_allEloc_cont(:,5,Ci) = mean(erdRetMobi_guess_allEloc_cont(:,:,Ci), 2);
    meanTime_allEloc_cont(:,6,Ci) = mean(erdRetDesk_guess_allEloc_cont(:,:,Ci), 2);
    meanTime_allEloc_cont(:,7,Ci) = mean(erdRetMobi_all_allEloc_cont(:,:,Ci), 2);
    meanTime_allEloc_cont(:,8,Ci) = mean(erdRetDesk_all_allEloc_cont(:,:,Ci), 2);
    
end


% save them

table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverTime';

save(fullfile(table_path,'meanTime_fm_pat.mat'), 'meanTime_fm_pat');
save(fullfile(table_path,'meanTime_fm_cont.mat'), 'meanTime_fm_cont');
save(fullfile(table_path,'meanTime_allEloc_pat.mat'), 'meanTime_allEloc_pat');
save(fullfile(table_path,'meanTime_allEloc_cont.mat'), 'meanTime_allEloc_cont');


% 3. Create theta matricies and tables that includes average of ERD values
% over electrodes (time is already averaged)
%---------------------------------------------------------------------------

% loop over patients
for Pi = 1:numel(patients)
    
    meanEloc_fm_pat(Pi,:)      = mean(meanTime_fm_pat(:,:,Pi), 1);
    meanEloc_allEloc_pat(Pi,:) = mean(meanTime_allEloc_pat(:,:,Pi), 1);
    
end    

% loop over controls
for Ci = 1:numel(controls)
    
    meanEloc_fm_cont(Ci,:)      = mean(meanTime_fm_cont(:,:,Ci), 1);
    meanEloc_allEloc_cont(Ci,:) = mean(meanTime_allEloc_cont(:,:,Ci), 1);
    
end


table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc';

patients = cellstr(string(patients));
controls = cellstr(string(controls));

column_names = {'Encoding_all-MoBI','Encoding_all-Desktop','Encoding_2_3-MoBI','Encoding_2_3-Desktop',...
    'Retrieval_guess-MoBI','Retrieval_guess-Desktop', 'Retrieval_all-MoBI', 'Retrieval_all-Desktop'};

% create theta tables and save them
%-----------------------------------
table_meanEloc_fm_pat       = array2table(meanEloc_fm_pat, 'VariableNames', column_names, 'RowNames',patients);
table_meanEloc_fm_cont      = array2table(meanEloc_fm_cont, 'VariableNames', column_names, 'RowNames',controls);
table_meanEloc_allEloc_pat  = array2table(meanEloc_allEloc_pat, 'VariableNames', column_names, 'RowNames',patients);
table_meanEloc_allEloc_cont = array2table(meanEloc_allEloc_cont, 'VariableNames', column_names, 'RowNames',controls);

save(fullfile(table_path,'table_meanEloc_fm_pat.mat'),'table_meanEloc_fm_pat');
save(fullfile(table_path,'table_meanEloc_fm_cont.mat'),'table_meanEloc_fm_cont');
save(fullfile(table_path,'table_meanEloc_allEloc_pat.mat'),'table_meanEloc_allEloc_pat');
save(fullfile(table_path,'table_meanEloc_allEloc_cont.mat'),'table_meanEloc_allEloc_cont');

%--------------------------------------
% save them also as matricies
save(fullfile(table_path,'meanEloc_fm_pat.mat'), 'meanEloc_fm_pat');
save(fullfile(table_path,'meanEloc_fm_cont.mat'), 'meanEloc_fm_cont');
save(fullfile(table_path,'meanEloc_allEloc_pat.mat'), 'meanEloc_allEloc_pat');
save(fullfile(table_path,'meanEloc_allEloc_cont.mat'), 'meanEloc_allEloc_cont');

% save the epoch variance matricies
save(fullfile(table_path,'varEpoch_enc_all_Mobi_p.mat'), 'varEpoch_enc_all_Mobi_p');
save(fullfile(table_path,'varEpoch_enc_all_Desk_p.mat'), 'varEpoch_enc_all_Desk_p');
save(fullfile(table_path,'varEpoch_enc_2_3_Mobi_p.mat'), 'varEpoch_enc_2_3_Mobi_p');
save(fullfile(table_path,'varEpoch_enc_2_3_Desk_p.mat'), 'varEpoch_enc_2_3_Desk_p');
save(fullfile(table_path,'varEpoch_ret_guess_Mobi_p.mat'), 'varEpoch_ret_guess_Mobi_p');
save(fullfile(table_path,'varEpoch_ret_guess_Desk_p.mat'), 'varEpoch_ret_guess_Desk_p');
save(fullfile(table_path,'varEpoch_ret_all_Mobi_p.mat'), 'varEpoch_ret_all_Mobi_p');
save(fullfile(table_path,'varEpoch_ret_all_Desk_p.mat'), 'varEpoch_ret_all_Desk_p');

save(fullfile(table_path,'varEpoch_enc_all_Mobi_c.mat'), 'varEpoch_enc_all_Mobi_c');
save(fullfile(table_path,'varEpoch_enc_all_Desk_c.mat'), 'varEpoch_enc_all_Desk_c');
save(fullfile(table_path,'varEpoch_enc_2_3_Mobi_c.mat'), 'varEpoch_enc_2_3_Mobi_c');
save(fullfile(table_path,'varEpoch_enc_2_3_Desk_c.mat'), 'varEpoch_enc_2_3_Desk_c');
save(fullfile(table_path,'varEpoch_ret_guess_Mobi_c.mat'), 'varEpoch_ret_guess_Mobi_c');
save(fullfile(table_path,'varEpoch_ret_guess_Desk_c.mat'), 'varEpoch_ret_guess_Desk_c');
save(fullfile(table_path,'varEpoch_ret_all_Mobi_c.mat'), 'varEpoch_ret_all_Mobi_c');
save(fullfile(table_path,'varEpoch_ret_all_Desk_c.mat'), 'varEpoch_ret_all_Desk_c');


%% STEP 04.2: ERD Calculation / Rotation
% create matricies and tables that includes all participants
% rotated/unrotated retrieval epochs

% seperate patient and control participants
patients = [];
controls = [];
count_p = 1; % patients count
count_c = 1; % controls count


% 1. Create matricies that includes each electrodes separetely
%----------------------------------------------------------------------

% loop over participants
for Pi = 1:numel(participantsPreproc)
    
    subject                    = participantsPreproc(Pi);
    participantFolder          = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    epochedFileNameEEG         = [num2str(subject') '_epoched.set'];
    epochedBaselineFileNameEEG = [num2str(subject') '_epoched_baseline.set'];
    epochedEEG                 =  pop_loadset('filepath', participantFolder ,'filename', epochedFileNameEEG);
    epochedEEG_baseline        =  pop_loadset('filepath', participantFolder ,'filename', epochedBaselineFileNameEEG);
  
    
    % create different matricies for patients and controls
    if contains(num2str(subject), '81') == 1
        [rotation_var_fm, rotation_var_allEloc, rotation_erd_fm, rotation_erd_allEloc] = WM_04_ERD2_rotation(epochedEEG, epochedEEG_baseline);
        
        rot0MoBI_varfm_p_guess(:,:,count_p)   = rotation_var_fm(:,:,1);
        rot0Desk_varfm_p_guess(:,:,count_p)   = rotation_var_fm(:,:,2);
        rot90MoBI_varfm_p_guess(:,:,count_p)  = rotation_var_fm(:,:,3);
        rot90Desk_varfm_p_guess(:,:,count_p)  = rotation_var_fm(:,:,4);
        rot180MoBI_varfm_p_guess(:,:,count_p) = rotation_var_fm(:,:,5);
        rot180Desk_varfm_p_guess(:,:,count_p) = rotation_var_fm(:,:,6);
        rot270MoBI_varfm_p_guess(:,:,count_p) = rotation_var_fm(:,:,7);
        rot270Desk_varfm_p_guess(:,:,count_p) = rotation_var_fm(:,:,8);
        
        rot0MoBI_varfm_p_all(:,:,count_p)   = rotation_var_fm(:,:,9);
        rot0Desk_varfm_p_all(:,:,count_p)   = rotation_var_fm(:,:,10);
        rot90MoBI_varfm_p_all(:,:,count_p)  = rotation_var_fm(:,:,11);
        rot90Desk_varfm_p_all(:,:,count_p)  = rotation_var_fm(:,:,12);
        rot180MoBI_varfm_p_all(:,:,count_p) = rotation_var_fm(:,:,13);
        rot180Desk_varfm_p_all(:,:,count_p) = rotation_var_fm(:,:,14);
        rot270MoBI_varfm_p_all(:,:,count_p) = rotation_var_fm(:,:,15);
        rot270Desk_varfm_p_all(:,:,count_p) = rotation_var_fm(:,:,16);
        
        rot0MoBI_varall_p_guess(:,:,count_p)   = rotation_var_allEloc(:,:,1);
        rot0Desk_varall_p_guess(:,:,count_p)   = rotation_var_allEloc(:,:,2);
        rot90MoBI_varall_p_guess(:,:,count_p)  = rotation_var_allEloc(:,:,3);
        rot90Desk_varall_p_guess(:,:,count_p)  = rotation_var_allEloc(:,:,4);
        rot180MoBI_varall_p_guess(:,:,count_p) = rotation_var_allEloc(:,:,5);
        rot180Desk_varall_p_guess(:,:,count_p) = rotation_var_allEloc(:,:,6);
        rot270MoBI_varall_p_guess(:,:,count_p) = rotation_var_allEloc(:,:,7);
        rot270Desk_varall_p_guess(:,:,count_p) = rotation_var_allEloc(:,:,8);
        
        rot0MoBI_varall_p_all(:,:,count_p)   = rotation_var_allEloc(:,:,9);
        rot0Desk_varall_p_all(:,:,count_p)   = rotation_var_allEloc(:,:,10);
        rot90MoBI_varall_p_all(:,:,count_p)  = rotation_var_allEloc(:,:,11);
        rot90Desk_varall_p_all(:,:,count_p)  = rotation_var_allEloc(:,:,12);
        rot180MoBI_varall_p_all(:,:,count_p) = rotation_var_allEloc(:,:,13);
        rot180Desk_varall_p_all(:,:,count_p) = rotation_var_allEloc(:,:,14);
        rot270MoBI_varall_p_all(:,:,count_p) = rotation_var_allEloc(:,:,15);
        rot270Desk_varall_p_all(:,:,count_p) = rotation_var_allEloc(:,:,16);
        
        
        rot0MoBI_erdfm_p_guess(:,:,count_p)   = rotation_erd_fm(:,:,1);
        rot0Desk_erdfm_p_guess(:,:,count_p)   = rotation_erd_fm(:,:,2);
        rot90MoBI_erdfm_p_guess(:,:,count_p)  = rotation_erd_fm(:,:,3);
        rot90Desk_erdfm_p_guess(:,:,count_p)  = rotation_erd_fm(:,:,4);
        rot180MoBI_erdfm_p_guess(:,:,count_p) = rotation_erd_fm(:,:,5);
        rot180Desk_erdfm_p_guess(:,:,count_p) = rotation_erd_fm(:,:,6);
        rot270MoBI_erdfm_p_guess(:,:,count_p) = rotation_erd_fm(:,:,7);
        rot270Desk_erdfm_p_guess(:,:,count_p) = rotation_erd_fm(:,:,8);
        
        rot0MoBI_erdfm_p_all(:,:,count_p)   = rotation_erd_fm(:,:,9);
        rot0Desk_erdfm_p_all(:,:,count_p)   = rotation_erd_fm(:,:,10);
        rot90MoBI_erdfm_p_all(:,:,count_p)  = rotation_erd_fm(:,:,11);
        rot90Desk_erdfm_p_all(:,:,count_p)  = rotation_erd_fm(:,:,12);
        rot180MoBI_erdfm_p_all(:,:,count_p) = rotation_erd_fm(:,:,13);
        rot180Desk_erdfm_p_all(:,:,count_p) = rotation_erd_fm(:,:,14);
        rot270MoBI_erdfm_p_all(:,:,count_p) = rotation_erd_fm(:,:,15);
        rot270Desk_erdfm_p_all(:,:,count_p) = rotation_erd_fm(:,:,16);
        
        rot0MoBI_erdall_p_guess(:,:,count_p)   = rotation_erd_allEloc(:,:,1);
        rot0Desk_erdall_p_guess(:,:,count_p)   = rotation_erd_allEloc(:,:,2);
        rot90MoBI_erdall_p_guess(:,:,count_p)  = rotation_erd_allEloc(:,:,3);
        rot90Desk_erdall_p_guess(:,:,count_p)  = rotation_erd_allEloc(:,:,4);
        rot180MoBI_erdall_p_guess(:,:,count_p) = rotation_erd_allEloc(:,:,5);
        rot180Desk_erdall_p_guess(:,:,count_p) = rotation_erd_allEloc(:,:,6);
        rot270MoBI_erdall_p_guess(:,:,count_p) = rotation_erd_allEloc(:,:,7);
        rot270Desk_erdall_p_guess(:,:,count_p) = rotation_erd_allEloc(:,:,8);
        
        rot0MoBI_erdall_p_all(:,:,count_p)   = rotation_erd_allEloc(:,:,9);
        rot0Desk_erdall_p_all(:,:,count_p)   = rotation_erd_allEloc(:,:,10);
        rot90MoBI_erdall_p_all(:,:,count_p)  = rotation_erd_allEloc(:,:,11);
        rot90Desk_erdall_p_all(:,:,count_p)  = rotation_erd_allEloc(:,:,12);
        rot180MoBI_erdall_p_all(:,:,count_p) = rotation_erd_allEloc(:,:,13);
        rot180Desk_erdall_p_all(:,:,count_p) = rotation_erd_allEloc(:,:,14);
        rot270MoBI_erdall_p_all(:,:,count_p) = rotation_erd_allEloc(:,:,15);
        rot270Desk_erdall_p_all(:,:,count_p) = rotation_erd_allEloc(:,:,16);
        
        patients(count_p) = subject; 
        count_p = count_p + 1;
        
    else
        [rotation_var_fm, rotation_var_allEloc, rotation_erd_fm, rotation_erd_allEloc] = WM_04_ERD2_rotation(epochedEEG, epochedEEG_baseline);

        rot0MoBI_varfm_c_guess(:,:,count_c)   = rotation_var_fm(:,:,1);
        rot0Desk_varfm_c_guess(:,:,count_c)   = rotation_var_fm(:,:,2);
        rot90MoBI_varfm_c_guess(:,:,count_c)  = rotation_var_fm(:,:,3);
        rot90Desk_varfm_c_guess(:,:,count_c)  = rotation_var_fm(:,:,4);
        rot180MoBI_varfm_c_guess(:,:,count_c) = rotation_var_fm(:,:,5);
        rot180Desk_varfm_c_guess(:,:,count_c) = rotation_var_fm(:,:,6);
        rot270MoBI_varfm_c_guess(:,:,count_c) = rotation_var_fm(:,:,7);
        rot270Desk_varfm_c_guess(:,:,count_c) = rotation_var_fm(:,:,8);
        
        rot0MoBI_varfm_c_all(:,:,count_c)   = rotation_var_fm(:,:,9);
        rot0Desk_varfm_c_all(:,:,count_c)   = rotation_var_fm(:,:,10);
        rot90MoBI_varfm_c_all(:,:,count_c)  = rotation_var_fm(:,:,11);
        rot90Desk_varfm_c_all(:,:,count_c)  = rotation_var_fm(:,:,12);
        rot180MoBI_varfm_c_all(:,:,count_c) = rotation_var_fm(:,:,13);
        rot180Desk_varfm_c_all(:,:,count_c) = rotation_var_fm(:,:,14);
        rot270MoBI_varfm_c_all(:,:,count_c) = rotation_var_fm(:,:,15);
        rot270Desk_varfm_c_all(:,:,count_c) = rotation_var_fm(:,:,16);
        
        rot0MoBI_varall_c_guess(:,:,count_c)   = rotation_var_allEloc(:,:,1);
        rot0Desk_varall_c_guess(:,:,count_c)   = rotation_var_allEloc(:,:,2);
        rot90MoBI_varall_c_guess(:,:,count_c)  = rotation_var_allEloc(:,:,3);
        rot90Desk_varall_c_guess(:,:,count_c)  = rotation_var_allEloc(:,:,4);
        rot180MoBI_varall_c_guess(:,:,count_c) = rotation_var_allEloc(:,:,5);
        rot180Desk_varall_c_guess(:,:,count_c) = rotation_var_allEloc(:,:,6);
        rot270MoBI_varall_c_guess(:,:,count_c) = rotation_var_allEloc(:,:,7);
        rot270Desk_varall_c_guess(:,:,count_c) = rotation_var_allEloc(:,:,8);
        
        rot0MoBI_varall_c_all(:,:,count_c)   = rotation_var_allEloc(:,:,9);
        rot0Desk_varall_c_all(:,:,count_c)   = rotation_var_allEloc(:,:,10);
        rot90MoBI_varall_c_all(:,:,count_c)  = rotation_var_allEloc(:,:,11);
        rot90Desk_varall_c_all(:,:,count_c)  = rotation_var_allEloc(:,:,12);
        rot180MoBI_varall_c_all(:,:,count_c) = rotation_var_allEloc(:,:,13);
        rot180Desk_varall_c_all(:,:,count_c) = rotation_var_allEloc(:,:,14);
        rot270MoBI_varall_c_all(:,:,count_c) = rotation_var_allEloc(:,:,15);
        rot270Desk_varall_c_all(:,:,count_c) = rotation_var_allEloc(:,:,16);
        
        
        rot0MoBI_erdfm_c_guess(:,:,count_c)   = rotation_erd_fm(:,:,1);
        rot0Desk_erdfm_c_guess(:,:,count_c)   = rotation_erd_fm(:,:,2);
        rot90MoBI_erdfm_c_guess(:,:,count_c)  = rotation_erd_fm(:,:,3);
        rot90Desk_erdfm_c_guess(:,:,count_c)  = rotation_erd_fm(:,:,4);
        rot180MoBI_erdfm_c_guess(:,:,count_c) = rotation_erd_fm(:,:,5);
        rot180Desk_erdfm_c_guess(:,:,count_c) = rotation_erd_fm(:,:,6);
        rot270MoBI_erdfm_c_guess(:,:,count_c) = rotation_erd_fm(:,:,7);
        rot270Desk_erdfm_c_guess(:,:,count_c) = rotation_erd_fm(:,:,8);
        
        rot0MoBI_erdfm_c_all(:,:,count_c)   = rotation_erd_fm(:,:,9);
        rot0Desk_erdfm_c_all(:,:,count_c)   = rotation_erd_fm(:,:,10);
        rot90MoBI_erdfm_c_all(:,:,count_c)  = rotation_erd_fm(:,:,11);
        rot90Desk_erdfm_c_all(:,:,count_c)  = rotation_erd_fm(:,:,12);
        rot180MoBI_erdfm_c_all(:,:,count_c) = rotation_erd_fm(:,:,13);
        rot180Desk_erdfm_c_all(:,:,count_c) = rotation_erd_fm(:,:,14);
        rot270MoBI_erdfm_c_all(:,:,count_c) = rotation_erd_fm(:,:,15);
        rot270Desk_erdfm_c_all(:,:,count_c) = rotation_erd_fm(:,:,16);
        
        rot0MoBI_erdall_c_guess(:,:,count_c)   = rotation_erd_allEloc(:,:,1);
        rot0Desk_erdall_c_guess(:,:,count_c)   = rotation_erd_allEloc(:,:,2);
        rot90MoBI_erdall_c_guess(:,:,count_c)  = rotation_erd_allEloc(:,:,3);
        rot90Desk_erdall_c_guess(:,:,count_c)  = rotation_erd_allEloc(:,:,4);
        rot180MoBI_erdall_c_guess(:,:,count_c) = rotation_erd_allEloc(:,:,5);
        rot180Desk_erdall_c_guess(:,:,count_c) = rotation_erd_allEloc(:,:,6);
        rot270MoBI_erdall_c_guess(:,:,count_c) = rotation_erd_allEloc(:,:,7);
        rot270Desk_erdall_c_guess(:,:,count_c) = rotation_erd_allEloc(:,:,8);
        
        rot0MoBI_erdall_c_all(:,:,count_c)   = rotation_erd_allEloc(:,:,9);
        rot0Desk_erdall_c_all(:,:,count_c)   = rotation_erd_allEloc(:,:,10);
        rot90MoBI_erdall_c_all(:,:,count_c)  = rotation_erd_allEloc(:,:,11);
        rot90Desk_erdall_c_all(:,:,count_c)  = rotation_erd_allEloc(:,:,12);
        rot180MoBI_erdall_c_all(:,:,count_c) = rotation_erd_allEloc(:,:,13);
        rot180Desk_erdall_c_all(:,:,count_c) = rotation_erd_allEloc(:,:,14);
        rot270MoBI_erdall_c_all(:,:,count_c) = rotation_erd_allEloc(:,:,15);
        rot270Desk_erdall_c_all(:,:,count_c) = rotation_erd_allEloc(:,:,16);
        
        controls(count_c) = subject; 
        count_c = count_c + 1;
        
    end    
    
end    


% save the matricies
% 3D matricies: 
% First dimension: electrodes
% Second dimension: data points
% Third dimension: participants

table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\IntertrialVariance\Rotation';

save(fullfile(table_path,'rot0MoBI_varfm_p_guess.mat'), 'rot0MoBI_varfm_p_guess');
save(fullfile(table_path,'rot0Desk_varfm_p_guess.mat'), 'rot0Desk_varfm_p_guess');
save(fullfile(table_path,'rot90MoBI_varfm_p_guess.mat'), 'rot90MoBI_varfm_p_guess');
save(fullfile(table_path,'rot90Desk_varfm_p_guess.mat'), 'rot90Desk_varfm_p_guess');
save(fullfile(table_path,'rot180MoBI_varfm_p_guess.mat'), 'rot180MoBI_varfm_p_guess');
save(fullfile(table_path,'rot180Desk_varfm_p_guess.mat'), 'rot180Desk_varfm_p_guess');
save(fullfile(table_path,'rot270MoBI_varfm_p_guess.mat'), 'rot270MoBI_varfm_p_guess');
save(fullfile(table_path,'rot270Desk_varfm_p_guess.mat'), 'rot270Desk_varfm_p_guess');

save(fullfile(table_path,'rot0MoBI_varfm_p_all.mat'), 'rot0MoBI_varfm_p_all');
save(fullfile(table_path,'rot0Desk_varfm_p_all.mat'), 'rot0Desk_varfm_p_all');
save(fullfile(table_path,'rot90MoBI_varfm_p_all.mat'), 'rot90MoBI_varfm_p_all');
save(fullfile(table_path,'rot90Desk_varfm_p_all.mat'), 'rot90Desk_varfm_p_all');
save(fullfile(table_path,'rot180MoBI_varfm_p_all.mat'), 'rot180MoBI_varfm_p_all');
save(fullfile(table_path,'rot180Desk_varfm_p_all.mat'), 'rot180Desk_varfm_p_all');
save(fullfile(table_path,'rot270MoBI_varfm_p_all.mat'), 'rot270MoBI_varfm_p_all');
save(fullfile(table_path,'rot270Desk_varfm_p_all.mat'), 'rot270Desk_varfm_p_all');

save(fullfile(table_path,'rot0MoBI_varall_p_guess.mat'), 'rot0MoBI_varall_p_guess');
save(fullfile(table_path,'rot0Desk_varall_p_guess.mat'), 'rot0Desk_varall_p_guess');
save(fullfile(table_path,'rot90MoBI_varall_p_guess.mat'), 'rot90MoBI_varall_p_guess');
save(fullfile(table_path,'rot90Desk_varall_p_guess.mat'), 'rot90Desk_varall_p_guess');
save(fullfile(table_path,'rot180MoBI_varall_p_guess.mat'), 'rot180MoBI_varall_p_guess');
save(fullfile(table_path,'rot180Desk_varall_p_guess.mat'), 'rot180Desk_varall_p_guess');
save(fullfile(table_path,'rot270MoBI_varall_p_guess.mat'), 'rot270MoBI_varall_p_guess');
save(fullfile(table_path,'rot270Desk_varall_p_guess.mat'), 'rot270Desk_varall_p_guess');

save(fullfile(table_path,'rot0MoBI_varall_p_all.mat'), 'rot0MoBI_varall_p_all');
save(fullfile(table_path,'rot0Desk_varall_p_all.mat'), 'rot0Desk_varall_p_all');
save(fullfile(table_path,'rot90MoBI_varall_p_all.mat'), 'rot90MoBI_varall_p_all');
save(fullfile(table_path,'rot90Desk_varall_p_all.mat'), 'rot90Desk_varall_p_all');
save(fullfile(table_path,'rot180MoBI_varall_p_all.mat'), 'rot180MoBI_varall_p_all');
save(fullfile(table_path,'rot180Desk_varall_p_all.mat'), 'rot180Desk_varall_p_all');
save(fullfile(table_path,'rot270MoBI_varall_p_all.mat'), 'rot270MoBI_varall_p_all');
save(fullfile(table_path,'rot270Desk_varall_p_all.mat'), 'rot270Desk_varall_p_all');

save(fullfile(table_path,'rot0MoBI_varfm_c_guess.mat'), 'rot0MoBI_varfm_c_guess');
save(fullfile(table_path,'rot0Desk_varfm_c_guess.mat'), 'rot0Desk_varfm_c_guess');
save(fullfile(table_path,'rot90MoBI_varfm_c_guess.mat'), 'rot90MoBI_varfm_c_guess');
save(fullfile(table_path,'rot90Desk_varfm_c_guess.mat'), 'rot90Desk_varfm_c_guess');
save(fullfile(table_path,'rot180MoBI_varfm_c_guess.mat'), 'rot180MoBI_varfm_c_guess');
save(fullfile(table_path,'rot180Desk_varfm_c_guess.mat'), 'rot180Desk_varfm_c_guess');
save(fullfile(table_path,'rot270MoBI_varfm_c_guess.mat'), 'rot270MoBI_varfm_c_guess');
save(fullfile(table_path,'rot270Desk_varfm_c_guess.mat'), 'rot270Desk_varfm_c_guess');

save(fullfile(table_path,'rot0MoBI_varfm_c_all.mat'), 'rot0MoBI_varfm_c_all');
save(fullfile(table_path,'rot0Desk_varfm_c_all.mat'), 'rot0Desk_varfm_c_all');
save(fullfile(table_path,'rot90MoBI_varfm_c_all.mat'), 'rot90MoBI_varfm_c_all');
save(fullfile(table_path,'rot90Desk_varfm_c_all.mat'), 'rot90Desk_varfm_c_all');
save(fullfile(table_path,'rot180MoBI_varfm_c_all.mat'), 'rot180MoBI_varfm_c_all');
save(fullfile(table_path,'rot180Desk_varfm_c_all.mat'), 'rot180Desk_varfm_c_all');
save(fullfile(table_path,'rot270MoBI_varfm_c_all.mat'), 'rot270MoBI_varfm_c_all');
save(fullfile(table_path,'rot270Desk_varfm_c_all.mat'), 'rot270Desk_varfm_c_all');

save(fullfile(table_path,'rot0MoBI_varall_c_guess.mat'), 'rot0MoBI_varall_c_guess');
save(fullfile(table_path,'rot0Desk_varall_c_guess.mat'), 'rot0Desk_varall_c_guess');
save(fullfile(table_path,'rot90MoBI_varall_c_guess.mat'), 'rot90MoBI_varall_c_guess');
save(fullfile(table_path,'rot90Desk_varall_c_guess.mat'), 'rot90Desk_varall_c_guess');
save(fullfile(table_path,'rot180MoBI_varall_c_guess.mat'), 'rot180MoBI_varall_c_guess');
save(fullfile(table_path,'rot180Desk_varall_c_guess.mat'), 'rot180Desk_varall_c_guess');
save(fullfile(table_path,'rot270MoBI_varall_c_guess.mat'), 'rot270MoBI_varall_c_guess');
save(fullfile(table_path,'rot270Desk_varall_c_guess.mat'), 'rot270Desk_varall_c_guess');

save(fullfile(table_path,'rot0MoBI_varall_c_all.mat'), 'rot0MoBI_varall_c_all');
save(fullfile(table_path,'rot0Desk_varall_c_all.mat'), 'rot0Desk_varall_c_all');
save(fullfile(table_path,'rot90MoBI_varall_c_all.mat'), 'rot90MoBI_varall_c_all');
save(fullfile(table_path,'rot90Desk_varall_c_all.mat'), 'rot90Desk_varall_c_all');
save(fullfile(table_path,'rot180MoBI_varall_c_all.mat'), 'rot180MoBI_varall_c_all');
save(fullfile(table_path,'rot180Desk_varall_c_all.mat'), 'rot180Desk_varall_c_all');
save(fullfile(table_path,'rot270MoBI_varall_c_all.mat'), 'rot270MoBI_varall_c_all');
save(fullfile(table_path,'rot270Desk_varall_c_all.mat'), 'rot270Desk_varall_c_all');


% save the matricies
%---------------------------------------------------------

table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\ERD\Rotation';

save(fullfile(table_path,'rot0MoBI_erdfm_p_guess.mat'), 'rot0MoBI_erdfm_p_guess');
save(fullfile(table_path,'rot0Desk_erdfm_p_guess.mat'), 'rot0Desk_erdfm_p_guess');
save(fullfile(table_path,'rot90MoBI_erdfm_p_guess.mat'), 'rot90MoBI_erdfm_p_guess');
save(fullfile(table_path,'rot90Desk_erdfm_p_guess.mat'), 'rot90Desk_erdfm_p_guess');
save(fullfile(table_path,'rot180MoBI_erdfm_p_guess.mat'), 'rot180MoBI_erdfm_p_guess');
save(fullfile(table_path,'rot180Desk_erdfm_p_guess.mat'), 'rot180Desk_erdfm_p_guess');
save(fullfile(table_path,'rot270MoBI_erdfm_p_guess.mat'), 'rot270MoBI_erdfm_p_guess');
save(fullfile(table_path,'rot270Desk_erdfm_p_guess.mat'), 'rot270Desk_erdfm_p_guess');

save(fullfile(table_path,'rot0MoBI_erdfm_p_all.mat'), 'rot0MoBI_erdfm_p_all');
save(fullfile(table_path,'rot0Desk_erdfm_p_all.mat'), 'rot0Desk_erdfm_p_all');
save(fullfile(table_path,'rot90MoBI_erdfm_p_all.mat'), 'rot90MoBI_erdfm_p_all');
save(fullfile(table_path,'rot90Desk_erdfm_p_all.mat'), 'rot90Desk_erdfm_p_all');
save(fullfile(table_path,'rot180MoBI_erdfm_p_all.mat'), 'rot180MoBI_erdfm_p_all');
save(fullfile(table_path,'rot180Desk_erdfm_p_all.mat'), 'rot180Desk_erdfm_p_all');
save(fullfile(table_path,'rot270MoBI_erdfm_p_all.mat'), 'rot270MoBI_erdfm_p_all');
save(fullfile(table_path,'rot270Desk_erdfm_p_all.mat'), 'rot270Desk_erdfm_p_all');

save(fullfile(table_path,'rot0MoBI_erdall_p_guess.mat'), 'rot0MoBI_erdall_p_guess');
save(fullfile(table_path,'rot0Desk_erdall_p_guess.mat'), 'rot0Desk_erdall_p_guess');
save(fullfile(table_path,'rot90MoBI_erdall_p_guess.mat'), 'rot90MoBI_erdall_p_guess');
save(fullfile(table_path,'rot90Desk_erdall_p_guess.mat'), 'rot90Desk_erdall_p_guess');
save(fullfile(table_path,'rot180MoBI_erdall_p_guess.mat'), 'rot180MoBI_erdall_p_guess');
save(fullfile(table_path,'rot180Desk_erdall_p_guess.mat'), 'rot180Desk_erdall_p_guess');
save(fullfile(table_path,'rot270MoBI_erdall_p_guess.mat'), 'rot270MoBI_erdall_p_guess');
save(fullfile(table_path,'rot270Desk_erdall_p_guess.mat'), 'rot270Desk_erdall_p_guess');

save(fullfile(table_path,'rot0MoBI_erdall_p_all.mat'), 'rot0MoBI_erdall_p_all');
save(fullfile(table_path,'rot0Desk_erdall_p_all.mat'), 'rot0Desk_erdall_p_all');
save(fullfile(table_path,'rot90MoBI_erdall_p_all.mat'), 'rot90MoBI_erdall_p_all');
save(fullfile(table_path,'rot90Desk_erdall_p_all.mat'), 'rot90Desk_erdall_p_all');
save(fullfile(table_path,'rot180MoBI_erdall_p_all.mat'), 'rot180MoBI_erdall_p_all');
save(fullfile(table_path,'rot180Desk_erdall_p_all.mat'), 'rot180Desk_erdall_p_all');
save(fullfile(table_path,'rot270MoBI_erdall_p_all.mat'), 'rot270MoBI_erdall_p_all');
save(fullfile(table_path,'rot270Desk_erdall_p_all.mat'), 'rot270Desk_erdall_p_all');

save(fullfile(table_path,'rot0MoBI_erdfm_c_guess.mat'), 'rot0MoBI_erdfm_c_guess');
save(fullfile(table_path,'rot0Desk_erdfm_c_guess.mat'), 'rot0Desk_erdfm_c_guess');
save(fullfile(table_path,'rot90MoBI_erdfm_c_guess.mat'), 'rot90MoBI_erdfm_c_guess');
save(fullfile(table_path,'rot90Desk_erdfm_c_guess.mat'), 'rot90Desk_erdfm_c_guess');
save(fullfile(table_path,'rot180MoBI_erdfm_c_guess.mat'), 'rot180MoBI_erdfm_c_guess');
save(fullfile(table_path,'rot180Desk_erdfm_c_guess.mat'), 'rot180Desk_erdfm_c_guess');
save(fullfile(table_path,'rot270MoBI_erdfm_c_guess.mat'), 'rot270MoBI_erdfm_c_guess');
save(fullfile(table_path,'rot270Desk_erdfm_c_guess.mat'), 'rot270Desk_erdfm_c_guess');

save(fullfile(table_path,'rot0MoBI_erdfm_c.mat_all'), 'rot0MoBI_erdfm_c_all');
save(fullfile(table_path,'rot0Desk_erdfm_c.mat_all'), 'rot0Desk_erdfm_c_all');
save(fullfile(table_path,'rot90MoBI_erdfm_c.mat_all'), 'rot90MoBI_erdfm_c_all');
save(fullfile(table_path,'rot90Desk_erdfm_c.mat_all'), 'rot90Desk_erdfm_c_all');
save(fullfile(table_path,'rot180MoBI_erdfm_c.mat_all'), 'rot180MoBI_erdfm_c_all');
save(fullfile(table_path,'rot180Desk_erdfm_c.mat_all'), 'rot180Desk_erdfm_c_all');
save(fullfile(table_path,'rot270MoBI_erdfm_c.mat_all'), 'rot270MoBI_erdfm_c_all');
save(fullfile(table_path,'rot270Desk_erdfm_c.mat_all'), 'rot270Desk_erdfm_c_all');

save(fullfile(table_path,'rot0MoBI_erdall_c_guess.mat'), 'rot0MoBI_erdall_c_guess');
save(fullfile(table_path,'rot0Desk_erdall_c_guess.mat'), 'rot0Desk_erdall_c_guess');
save(fullfile(table_path,'rot90MoBI_erdall_c_guess.mat'), 'rot90MoBI_erdall_c_guess');
save(fullfile(table_path,'rot90Desk_erdall_c_guess.mat'), 'rot90Desk_erdall_c_guess');
save(fullfile(table_path,'rot180MoBI_erdall_c_guess.mat'), 'rot180MoBI_erdall_c_guess');
save(fullfile(table_path,'rot180Desk_erdall_c_guess.mat'), 'rot180Desk_erdall_c_guess');
save(fullfile(table_path,'rot270MoBI_erdall_c_guess.mat'), 'rot270MoBI_erdall_c_guess');
save(fullfile(table_path,'rot270Desk_erdall_c_guess.mat'), 'rot270Desk_erdall_c_guess');

save(fullfile(table_path,'rot0MoBI_erdall_c_all.mat'), 'rot0MoBI_erdall_c_all');
save(fullfile(table_path,'rot0Desk_erdall_c_all.mat'), 'rot0Desk_erdall_c_all');
save(fullfile(table_path,'rot90MoBI_erdall_c_all.mat'), 'rot90MoBI_erdall_c_all');
save(fullfile(table_path,'rot90Desk_erdall_c_all.mat'), 'rot90Desk_erdall_c_all');
save(fullfile(table_path,'rot180MoBI_erdall_c_all.mat'), 'rot180MoBI_erdall_c_all');
save(fullfile(table_path,'rot180Desk_erdall_c_all.mat'), 'rot180Desk_erdall_c_all');
save(fullfile(table_path,'rot270MoBI_erdall_c_all.mat'), 'rot270MoBI_erdall_c_all');
save(fullfile(table_path,'rot270Desk_erdall_c_all.mat'), 'rot270Desk_erdall_c_all');



% 2. Create theta matricies and tables that includes average of ERD values
% over data points
%---------------------------------------------------------------------------

% loop over patients
for Pi = 1:numel(patients)
    
    rot_meanTime_fm_p(:,1,Pi)  = mean(rot0MoBI_erdfm_p_guess(:,:,Pi), 2);
    rot_meanTime_fm_p(:,2,Pi)  = mean(rot0Desk_erdfm_p_guess(:,:,Pi), 2);
    rot_meanTime_fm_p(:,3,Pi)  = mean(rot90MoBI_erdfm_p_guess(:,:,Pi), 2);
    rot_meanTime_fm_p(:,4,Pi)  = mean(rot90Desk_erdfm_p_guess(:,:,Pi), 2);
    rot_meanTime_fm_p(:,5,Pi)  = mean(rot180MoBI_erdfm_p_guess(:,:,Pi), 2);
    rot_meanTime_fm_p(:,6,Pi)  = mean(rot180Desk_erdfm_p_guess(:,:,Pi), 2);
    rot_meanTime_fm_p(:,7,Pi)  = mean(rot270MoBI_erdfm_p_guess(:,:,Pi), 2);
    rot_meanTime_fm_p(:,8,Pi)  = mean(rot270Desk_erdfm_p_guess(:,:,Pi), 2);
    rot_meanTime_fm_p(:,9,Pi)  = mean(rot0MoBI_erdfm_p_all(:,:,Pi), 2);
    rot_meanTime_fm_p(:,10,Pi) = mean(rot0Desk_erdfm_p_all(:,:,Pi), 2);
    rot_meanTime_fm_p(:,11,Pi) = mean(rot90MoBI_erdfm_p_all(:,:,Pi), 2);
    rot_meanTime_fm_p(:,12,Pi) = mean(rot90Desk_erdfm_p_all(:,:,Pi), 2);
    rot_meanTime_fm_p(:,13,Pi) = mean(rot180MoBI_erdfm_p_all(:,:,Pi), 2);
    rot_meanTime_fm_p(:,14,Pi) = mean(rot180Desk_erdfm_p_all(:,:,Pi), 2);
    rot_meanTime_fm_p(:,15,Pi) = mean(rot270MoBI_erdfm_p_all(:,:,Pi), 2);
    rot_meanTime_fm_p(:,16,Pi) = mean(rot270Desk_erdfm_p_all(:,:,Pi), 2);
    
    rot_meanTime_all_p(:,1,Pi)  = mean(rot0MoBI_erdall_p_guess(:,:,Pi), 2);
    rot_meanTime_all_p(:,2,Pi)  = mean(rot0Desk_erdall_p_guess(:,:,Pi), 2);
    rot_meanTime_all_p(:,3,Pi)  = mean(rot90MoBI_erdall_p_guess(:,:,Pi), 2);
    rot_meanTime_all_p(:,4,Pi)  = mean(rot90Desk_erdall_p_guess(:,:,Pi), 2);
    rot_meanTime_all_p(:,5,Pi)  = mean(rot180MoBI_erdall_p_guess(:,:,Pi), 2);
    rot_meanTime_all_p(:,6,Pi)  = mean(rot180Desk_erdall_p_guess(:,:,Pi), 2);
    rot_meanTime_all_p(:,7,Pi)  = mean(rot270MoBI_erdall_p_guess(:,:,Pi), 2);
    rot_meanTime_all_p(:,8,Pi)  = mean(rot270Desk_erdall_p_guess(:,:,Pi), 2);
    rot_meanTime_all_p(:,9,Pi)  = mean(rot0MoBI_erdall_p_all(:,:,Pi), 2);
    rot_meanTime_all_p(:,10,Pi) = mean(rot0Desk_erdall_p_all(:,:,Pi), 2);
    rot_meanTime_all_p(:,11,Pi) = mean(rot90MoBI_erdall_p_all(:,:,Pi), 2);
    rot_meanTime_all_p(:,12,Pi) = mean(rot90Desk_erdall_p_all(:,:,Pi), 2);
    rot_meanTime_all_p(:,13,Pi) = mean(rot180MoBI_erdall_p_all(:,:,Pi), 2);
    rot_meanTime_all_p(:,14,Pi) = mean(rot180Desk_erdall_p_all(:,:,Pi), 2);
    rot_meanTime_all_p(:,15,Pi) = mean(rot270MoBI_erdall_p_all(:,:,Pi), 2);
    rot_meanTime_all_p(:,16,Pi) = mean(rot270Desk_erdall_p_all(:,:,Pi), 2);
    
    
end    

% loop over controls
for Ci = 1:numel(controls)
    
    rot_meanTime_fm_c(:,1,Ci)  = mean(rot0MoBI_erdfm_c_guess(:,:,Ci), 2);
    rot_meanTime_fm_c(:,2,Ci)  = mean(rot0Desk_erdfm_c_guess(:,:,Ci), 2);
    rot_meanTime_fm_c(:,3,Ci)  = mean(rot90MoBI_erdfm_c_guess(:,:,Ci), 2);
    rot_meanTime_fm_c(:,4,Ci)  = mean(rot90Desk_erdfm_c_guess(:,:,Ci), 2);
    rot_meanTime_fm_c(:,5,Ci)  = mean(rot180MoBI_erdfm_c_guess(:,:,Ci), 2);
    rot_meanTime_fm_c(:,6,Ci)  = mean(rot180Desk_erdfm_c_guess(:,:,Ci), 2);
    rot_meanTime_fm_c(:,7,Ci)  = mean(rot270MoBI_erdfm_c_guess(:,:,Ci), 2);
    rot_meanTime_fm_c(:,8,Ci)  = mean(rot270Desk_erdfm_c_guess(:,:,Ci), 2);
    rot_meanTime_fm_c(:,9,Ci)  = mean(rot0MoBI_erdfm_c_all(:,:,Ci), 2);
    rot_meanTime_fm_c(:,10,Ci) = mean(rot0Desk_erdfm_c_all(:,:,Ci), 2);
    rot_meanTime_fm_c(:,11,Ci) = mean(rot90MoBI_erdfm_c_all(:,:,Ci), 2);
    rot_meanTime_fm_c(:,12,Ci) = mean(rot90Desk_erdfm_c_all(:,:,Ci), 2);
    rot_meanTime_fm_c(:,13,Ci) = mean(rot180MoBI_erdfm_c_all(:,:,Ci), 2);
    rot_meanTime_fm_c(:,14,Ci) = mean(rot180Desk_erdfm_c_all(:,:,Ci), 2);
    rot_meanTime_fm_c(:,15,Ci) = mean(rot270MoBI_erdfm_c_all(:,:,Ci), 2);
    rot_meanTime_fm_c(:,16,Ci) = mean(rot270Desk_erdfm_c_all(:,:,Ci), 2);
    
    rot_meanTime_all_c(:,1,Ci) = mean(rot0MoBI_erdall_c_guess(:,:,Ci), 2);
    rot_meanTime_all_c(:,2,Ci) = mean(rot0Desk_erdall_c_guess(:,:,Ci), 2);
    rot_meanTime_all_c(:,3,Ci) = mean(rot90MoBI_erdall_c_guess(:,:,Ci), 2);
    rot_meanTime_all_c(:,4,Ci) = mean(rot90Desk_erdall_c_guess(:,:,Ci), 2);
    rot_meanTime_all_c(:,5,Ci) = mean(rot180MoBI_erdall_c_guess(:,:,Ci), 2);
    rot_meanTime_all_c(:,6,Ci) = mean(rot180Desk_erdall_c_guess(:,:,Ci), 2);
    rot_meanTime_all_c(:,7,Ci) = mean(rot270MoBI_erdall_c_guess(:,:,Ci), 2);
    rot_meanTime_all_c(:,8,Ci) = mean(rot270Desk_erdall_c_guess(:,:,Ci), 2);
    rot_meanTime_all_c(:,9,Ci) = mean(rot0MoBI_erdall_c_all(:,:,Ci), 2);
    rot_meanTime_all_c(:,10,Ci) = mean(rot0Desk_erdall_c_all(:,:,Ci), 2);
    rot_meanTime_all_c(:,11,Ci) = mean(rot90MoBI_erdall_c_all(:,:,Ci), 2);
    rot_meanTime_all_c(:,12,Ci) = mean(rot90Desk_erdall_c_all(:,:,Ci), 2);
    rot_meanTime_all_c(:,13,Ci) = mean(rot180MoBI_erdall_c_all(:,:,Ci), 2);
    rot_meanTime_all_c(:,14,Ci) = mean(rot180Desk_erdall_c_all(:,:,Ci), 2);
    rot_meanTime_all_c(:,15,Ci) = mean(rot270MoBI_erdall_c_all(:,:,Ci), 2);
    rot_meanTime_all_c(:,16,Ci) = mean(rot270Desk_erdall_c_all(:,:,Ci), 2);
    
end


% save them

table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverTime\Rotation';

save(fullfile(table_path,'rot_meanTime_fm_p.mat'), 'rot_meanTime_fm_p');
save(fullfile(table_path,'rot_meanTime_fm_c.mat'), 'rot_meanTime_fm_c');
save(fullfile(table_path,'rot_meanTime_all_p.mat'), 'rot_meanTime_all_p');
save(fullfile(table_path,'rot_meanTime_all_c.mat'), 'rot_meanTime_all_c');


% 3. Create theta matricies and tables that includes average of ERD values
% over electrodes (time is already averaged)
%---------------------------------------------------------------------------

% loop over patients
for Pi = 1:numel(patients)
    
    rot_meanEloc_fm_p(Pi,:)  = mean(rot_meanTime_fm_p(:,:,Pi), 1);
    rot_meanEloc_all_p(Pi,:) = mean(rot_meanTime_all_p(:,:,Pi), 1);
    
end    

% loop over controls
for Ci = 1:numel(controls)
    
    rot_meanEloc_fm_c(Ci,:)  = mean(rot_meanTime_fm_c(:,:,Ci), 1);
    rot_meanEloc_all_c(Ci,:) = mean(rot_meanTime_all_c(:,:,Ci), 1);
    
end



table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc\Rotation';

patients = cellstr(string(patients));
controls = cellstr(string(controls));

column_names = {'Rotation0-MoBI_guess','Rotation0-Desktop_guess','Rotation90-MoBI_guess','Rotation90-Desktop_guess',...
    'Rotation180-MoBI_guess','Rotation180-Desktop_guess','Rotation270-MoBI_guess','Rotation270-Desktop_guess',...
    'Rotation0-MoBI_all','Rotation0-Desktop_all','Rotation90-MoBI_all','Rotation90-Desktop_all',...
    'Rotation180-MoBI_all','Rotation180-Desktop_all','Rotation270-MoBI_all','Rotation270-Desktop_all'};

% create theta tables and save them
%-----------------------------------
table_rot_meanEloc_fm_p   = array2table(rot_meanEloc_fm_p, 'VariableNames', column_names, 'RowNames',patients);
table_rot_meanEloc_fm_c   = array2table(rot_meanEloc_fm_c, 'VariableNames', column_names, 'RowNames',controls);
table_rot_meanEloc_all_p  = array2table(rot_meanEloc_all_p, 'VariableNames', column_names, 'RowNames',patients);
table_rot_meanEloc_all_c  = array2table(rot_meanEloc_all_c, 'VariableNames', column_names, 'RowNames',controls);

save(fullfile(table_path,'table_rot_meanEloc_fm_p.mat'),'table_rot_meanEloc_fm_p');
save(fullfile(table_path,'table_rot_meanEloc_fm_c.mat'),'table_rot_meanEloc_fm_c');
save(fullfile(table_path,'table_rot_meanEloc_all_p.mat'),'table_rot_meanEloc_all_p');
save(fullfile(table_path,'table_rot_meanEloc_all_c.mat'),'table_rot_meanEloc_all_c');

%--------------------------------------
% save them also as matricies
save(fullfile(table_path,'rot_meanEloc_fm_p.mat'), 'rot_meanEloc_fm_p');
save(fullfile(table_path,'rot_meanEloc_fm_c.mat'), 'rot_meanEloc_fm_c');
save(fullfile(table_path,'rot_meanEloc_all_p.mat'), 'rot_meanEloc_all_p');
save(fullfile(table_path,'rot_meanEloc_all_c.mat'), 'rot_meanEloc_all_c');


%% STEP 04.3: Topographic Map


% load theta matricies 
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverTime\meanTime_allEloc_cont.mat')
load('C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverTime\meanTime_allEloc_pat.mat')


% seperate patient and control participants
count_p = 1; % patients count
count_c = 1; % controls count
patients = [];
controls = [];

% loop over subjects
for Si = 1:numel(participantsPreproc)
    
    subject = participantsPreproc(Si);
    
    if contains(num2str(subject), '81') == 1
        patients(count_p) = subject;
        count_p = count_p + 1;
        
    else
        controls(count_c) = subject;
        count_c = count_c + 1;
        
    end    
end


% loop over patients
for Pi = 1:numel(patients)
    
    subject                    = patients(Pi);
    participantFolder          = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    epochedFileNameEEG         = [num2str(subject') '_epoched.set'];
    epochedEEG                 =  pop_loadset('filepath', participantFolder ,'filename', epochedFileNameEEG);

    % Encoding-MoBI (all trials)
    f1 = figure(1);
    set(gcf,'Name','Patients Encoding-MoBI (all trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(3,4,Pi)
    title(num2str(subject))
    topoplot(meanTime_allEloc_pat(:,1,Pi), epochedEEG.chanlocs)
    sgtitle('Patients Encoding-MoBI (all trials)','fontweight','bold','fontsize',18)
    
    % Encoding-Desktop (all trials)
    f2 = figure(2);
    set(gcf,'Name','Patients Encoding-Desktop (all trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(3,4,Pi)
    title(num2str(subject))
    topoplot(meanTime_allEloc_pat(:,2,Pi), epochedEEG.chanlocs)
    sgtitle('Patients Encoding-Desktop (all trials)','fontweight','bold','fontsize',18)
    
    % Encoding-MoBI (2 & 3)
    f3 = figure(3);
    set(gcf,'Name','Patients Encoding-MoBI (2 & 3)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(3,4,Pi)
    title(num2str(subject))
    topoplot(meanTime_allEloc_pat(:,3,Pi), epochedEEG.chanlocs)
    sgtitle('Patients Encoding-MoBI (2 & 3)','fontweight','bold','fontsize',18)
    
    % Encoding-Desktop (2 & 3)
    f4 = figure(4);
    set(gcf,'Name','Patients Encoding-Desktop (2 & 3)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(3,4,Pi)
    title(num2str(subject))
    topoplot(meanTime_allEloc_pat(:,4,Pi), epochedEEG.chanlocs)
    sgtitle('Patients Encoding-Desktop (2 & 3)','fontweight','bold','fontsize',18)
    
    % Retrieval-MoBI (guess trials)
    f5 = figure(5);
    set(gcf,'Name','Patients Retrieval-MoBI (guess trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(3,4,Pi)
    title(num2str(subject))
    topoplot(meanTime_allEloc_pat(:,5,Pi), epochedEEG.chanlocs)
    sgtitle('Patients Retrieval-MoBI (guess trials)','fontweight','bold','fontsize',18)
    
    % Retrieval-Desktop (guess trials)
    f6 = figure(6);
    set(gcf,'Name','Patients Retrieval-Desktop (guess trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(3,4,Pi)
    title(num2str(subject))
    topoplot(meanTime_allEloc_pat(:,6,Pi), epochedEEG.chanlocs)
    sgtitle('Patients Retrieval-Desktop (guess trials)','fontweight','bold','fontsize',18)

    % Retrieval-MoBI (all trials)
    f7 = figure(7);
    set(gcf,'Name','Patients Retrieval-MoBI (all trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(3,4,Pi)
    title(num2str(subject))
    topoplot(meanTime_allEloc_pat(:,7,Pi), epochedEEG.chanlocs)
    sgtitle('Patients Retrieval-MoBI (all trials)','fontweight','bold','fontsize',18)
    
    % Retrieval-Desktop (all trials) 
    f8 = figure(8);
    set(gcf,'Name','Patients Retrieval-Desktop (all trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(3,4,Pi)
    title(num2str(subject))
    topoplot(meanTime_allEloc_pat(:,8,Pi), epochedEEG.chanlocs)
    sgtitle('Patients Retrieval-Desktop (all trials)','fontweight','bold','fontsize',18)
    
end


% loop over controls
for Ci = 1:numel(controls)
    
    subject                    = controls(Ci);
    participantFolder          = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    epochedFileNameEEG         = [num2str(subject') '_epoched.set'];
    epochedEEG                 =  pop_loadset('filepath', participantFolder ,'filename', epochedFileNameEEG);

    % Encoding-MoBI (all trials)
    f9 = figure(9);
    set(gcf,'Name','Controls Encoding-MoBI (all trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4,5,Ci)
    title(num2str(subject))
    topoplot(meanTime_allEloc_cont(:,1,Ci), epochedEEG.chanlocs)
    sgtitle('Controls Encoding-MoBI (all trials)','fontweight','bold','fontsize',18)

    % Encoding-Desktop (all trials)
    f10 = figure(10);
    set(gcf,'Name','Controls Encoding-Desktop (all trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4,5,Ci)
    title(num2str(subject))
    topoplot(meanTime_allEloc_cont(:,2,Ci), epochedEEG.chanlocs)
    sgtitle('Controls Encoding-Desktop (all trials)','fontweight','bold','fontsize',18)
    
    % Encoding-MoBI (2 & 3)
    f11 = figure(11);
    set(gcf,'Name','Controls Encoding-MoBI (2 & 3)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4,5,Ci)
    title(num2str(subject))
    topoplot(meanTime_allEloc_cont(:,3,Ci), epochedEEG.chanlocs)
    sgtitle('Controls Encoding-MoBI (2 & 3)','fontweight','bold','fontsize',18)

    % Encoding-Desktop (2 & 3)
    f12 = figure(12);
    set(gcf,'Name','Controls Encoding-Desktop (2 & 3)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4,5,Ci)
    title(num2str(subject))
    topoplot(meanTime_allEloc_cont(:,4,Ci), epochedEEG.chanlocs)
    sgtitle('Controls Encoding-Desktop (2 & 3)','fontweight','bold','fontsize',18)
    
    % Retrieval-MoBI (guess trials)
    f13 = figure(13);
    set(gcf,'Name','Controls Retrieval-MoBI (guess trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4,5,Ci)
    title(num2str(subject))
    topoplot(meanTime_allEloc_cont(:,5,Ci), epochedEEG.chanlocs)
    sgtitle('Controls Retrieval-MoBI (guess trials)','fontweight','bold','fontsize',18)
    
    % Retrieval-Desktop (guess trials)
    f14 = figure(14);
    set(gcf,'Name','Contols Retrieval-Desktop (guess trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4,5,Ci)
    title(num2str(subject))
    topoplot(meanTime_allEloc_cont(:,6,Ci), epochedEEG.chanlocs)
    sgtitle('Contols Retrieval-Desktop (guess trials)','fontweight','bold','fontsize',18)
    
    % Retrieval-MoBI (all trials)
    f15 = figure(15);
    set(gcf,'Name','Controls Retrieval-MoBI (all trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4,5,Ci)
    title(num2str(subject))
    topoplot(meanTime_allEloc_cont(:,7,Ci), epochedEEG.chanlocs)
    sgtitle('Controls Retrieval-MoBI (all trials)','fontweight','bold','fontsize',18)
    
    % Retrieval-Desktop (all trials)
    f16 = figure(16);
    set(gcf,'Name','Contols Retrieval-Desktop (all trials)')
    set(gcf, 'Position', get(0, 'Screensize'));
    subplot(4,5,Ci)
    title(num2str(subject))
    topoplot(meanTime_allEloc_cont(:,8,Ci), epochedEEG.chanlocs)
    sgtitle('Contols Retrieval-Desktop (all trials)','fontweight','bold','fontsize',18)

end


%-----------------------------------------------------------------------
% create average topoplots for patients and controls

avg_p_en_m_all = mean(meanTime_allEloc_pat(:,1),3); % Patients - Encoding MoBI (all)
avg_p_en_d_all = mean(meanTime_allEloc_pat(:,2),3); % Patients - Encoding Desktop (all)
avg_p_en_m_2_3 = mean(meanTime_allEloc_pat(:,3),3); % Patients - Encoding MoBI (2 & 3)
avg_p_en_d_2_3 = mean(meanTime_allEloc_pat(:,4),3); % Patients - Encoding Desktop (2 & 3)

avg_p_re_m_guess = mean(meanTime_allEloc_pat(:,5),3); % Patients - Retrieval MoBI (guess)
avg_p_re_d_guess = mean(meanTime_allEloc_pat(:,6),3); % Patients - Retrieval Desktop (guess)
avg_p_re_m_all = mean(meanTime_allEloc_pat(:,7),3); % Patients - Retrieval MoBI (all)
avg_p_re_d_all = mean(meanTime_allEloc_pat(:,8),3); % Patients - Retrieval Desktop (all)

avg_c_en_m_all = mean(meanTime_allEloc_cont(:,1),3); % Controls - Encoding MoBI (all)
avg_c_en_d_all = mean(meanTime_allEloc_cont(:,2),3); % Controls - Encoding Desktop (all)
avg_c_en_m_2_3 = mean(meanTime_allEloc_cont(:,3),3); % Controls - Encoding MoBI (2 & 3)
avg_c_en_d_2_3 = mean(meanTime_allEloc_cont(:,4),3); % Controls - Encoding Desktop (2 & 3)

avg_c_re_m_guess = mean(meanTime_allEloc_cont(:,5),3); % Controls - Retrieval MoBI (guess)
avg_c_re_d_guess = mean(meanTime_allEloc_cont(:,6),3); % Controls - Retrieval Desktop (guess)
avg_c_re_m_all = mean(meanTime_allEloc_cont(:,7),3); % Controls - Retrieval MoBI (all)
avg_c_re_d_all = mean(meanTime_allEloc_cont(:,8),3); % Controls - Retrieval Desktop (all)

% select sample channel locations
patientEEG = pop_loadset('81001_epoched.set','C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Data\5_single-subject-EEG-analysis\81001');
controlEEG = pop_loadset('82001_epoched.set','C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Data\5_single-subject-EEG-analysis\82001');


% create encoding figure (all trials)

f17 = figure(17);

set(gcf,'Name','Encoding (all trials)')
set(gcf, 'Position', get(0, 'Screensize'));

subplot(2,2,1)
title('Patient MoBI')
topoplot(avg_p_en_m_all, patientEEG.chanlocs)

subplot(2,2,2)
title('Patient Desktop')
topoplot(avg_p_en_d_all, patientEEG.chanlocs)

subplot(2,2,3)
title('Control MoBI')
topoplot(avg_c_en_m_all, controlEEG.chanlocs)

subplot(2,2,4)
title('Control Desktop')
topoplot(avg_c_en_d_all, controlEEG.chanlocs)

sgtitle('Encoding (all trials)','fontweight','bold','fontsize',18)


% create encoding figure (2 & 3)

f18 = figure(18);

set(gcf,'Name','Encoding (2 & 3)')
set(gcf, 'Position', get(0, 'Screensize'));

subplot(2,2,1)
title('Patient MoBI')
topoplot(avg_p_en_m_2_3, patientEEG.chanlocs)

subplot(2,2,2)
title('Patient Desktop')
topoplot(avg_p_en_d_2_3, patientEEG.chanlocs)

subplot(2,2,3)
title('Control MoBI')
topoplot(avg_c_en_m_2_3, controlEEG.chanlocs)

subplot(2,2,4)
title('Control Desktop')
topoplot(avg_c_en_d_2_3, controlEEG.chanlocs)

sgtitle('Encoding (2 & 3)','fontweight','bold','fontsize',18)


% create retrieval figure (guess trials)

f19 = figure(19);

set(gcf,'Name','Retrieval (guess trials)')
set(gcf, 'Position', get(0, 'Screensize'));

subplot(2,2,1)
title('Patient MoBI')
topoplot(avg_p_re_m_guess, patientEEG.chanlocs)

subplot(2,2,2)
title('Patient Desktop')
topoplot(avg_p_re_d_guess, patientEEG.chanlocs)

subplot(2,2,3)
title('Control MoBI')
topoplot(avg_c_re_m_guess, controlEEG.chanlocs)

subplot(2,2,4)
title('Control Desktop')
topoplot(avg_c_re_d_guess, controlEEG.chanlocs)

sgtitle('Retrieval (guess trials)','fontweight','bold','fontsize',18)


% create retrieval figure (all trials)

f20 = figure(20);

set(gcf,'Name','Retrieval (all trials)')
set(gcf, 'Position', get(0, 'Screensize'));

subplot(2,2,1)
title('Patient MoBI')
topoplot(avg_p_re_m_all, patientEEG.chanlocs)

subplot(2,2,2)
title('Patient Desktop')
topoplot(avg_p_re_d_all, patientEEG.chanlocs)

subplot(2,2,3)
title('Control MoBI')
topoplot(avg_c_re_m_all, controlEEG.chanlocs)

subplot(2,2,4)
title('Control Desktop')
topoplot(avg_c_re_d_all, controlEEG.chanlocs)

sgtitle('Retrieval (all trials)','fontweight','bold','fontsize',18)


% save the figures
path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Graphs';

f = [f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12,f13,f14,f15,f16,f17,f18,f19,f20];

for i = 1:20
    
    saveas(f(i),fullfile(path,[['topo' num2str(i)],'.png']));

end



%% STEP 05: Theta Power Graphs

% WM_05_graphs.r


%% STEP 06: Regression Graphs

% First: Create search duration, distance error and position matricies
%------------------------------------------------------------------------

% seperate patient and control participants
count_p = 1; % patients count
count_c = 1; % controls count
patients = [];
controls = [];


% loop over subjects
for Si = 1:numel(participantsPreproc)
    
    subject = participantsPreproc(Si);
    
    if contains(num2str(subject), '81') == 1
        patients(count_p) = subject;
        count_p = count_p + 1;
        
    else
        controls(count_c) = subject;
        count_c = count_c + 1;
        
    end    
end
%


% create seperated matricies of search duration, distance error and positions for patients and controls
searchduration_patients = [];
searchduration_controls = [];
distance_error_patients = [];
distance_error_controls = [];
positions_patients      = [];
position_controls       = [];


% loop over patients
for Pi = 1:numel(patients)
    
    subject                    = patients(Pi);
    participantFolder          = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    preprocessedFileNameEEG    = [num2str(subject') '_cleaned_with_ICA.set'];
    EEG                        =  pop_loadset('filepath', participantFolder ,'filename', preprocessedFileNameEEG);
    
    [search_duration1,positions1,distance_error1] = WM_06_behavioral(EEG);
    searchduration_patients(:,Pi) = search_duration1;
    positions_patients(:,:,Pi)    = positions1;
    distance_error_patients(:,Pi) = distance_error1;
    

end


% loop over controls
for Ci = 1:numel(controls)
    
    subject                    = controls(Ci);
    participantFolder          = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    preprocessedFileNameEEG    = [num2str(subject') '_cleaned_with_ICA.set'];
    EEG                        =  pop_loadset('filepath', participantFolder ,'filename', preprocessedFileNameEEG);
    
    [search_duration2,positions2,distance_error2] = WM_06_behavioral(EEG);
    searchduration_controls(:,Ci) = search_duration2;
    positions_controls(:,:,Ci)    = positions2;
    distance_error_controls(:,Ci) = distance_error2;
    

end

% save them

table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\Behavioral';

save(fullfile(table_path,'searchduration_patients.mat'), 'searchduration_patients');
save(fullfile(table_path,'searchduration_controls.mat'), 'searchduration_controls');
save(fullfile(table_path,'positions_patients.mat'), 'positions_patients');
save(fullfile(table_path,'positions_controls.mat'), 'positions_controls');
save(fullfile(table_path,'distance_error_patients.mat'), 'distance_error_patients');
save(fullfile(table_path,'distance_error_controls.mat'), 'distance_error_controls');


% Second: Create ERD/Intertrial Variance matricies for regression analysis
%----------------------------------------------------------------------------


% loop over patients
for Pi = 1:numel(patients)
    
    subject                    = patients(Pi);
    participantFolder          = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    epochedFileNameEEG         = [num2str(subject') '_epoched.set'];
    epochedBaselineFileNameEEG = [num2str(subject') '_epoched_baseline.set'];
    epochedEEG                 =  pop_loadset('filepath', participantFolder ,'filename', epochedFileNameEEG);
    epochedEEG_baseline        =  pop_loadset('filepath', participantFolder ,'filename', epochedBaselineFileNameEEG);
    
    [erd_encoding_2_3, var_epoch_en, var_epoch_re] = WM_06_epochtheta(epochedEEG,epochedEEG_baseline);
    
    p_erd_encoding_2_3(Pi,:) = erd_encoding_2_3;
    p_var_epoch_en(:,:,Pi)   = var_epoch_en;
    p_var_epoch_re(:,:,Pi)   = var_epoch_re;

end


% loop over controls
for Ci = 1:numel(controls)
    
    subject                    = controls(Ci);
    participantFolder          = fullfile(bemobil_config.study_folder, bemobil_config.single_subject_analysis_folder, [num2str(subject)]);
    epochedFileNameEEG         = [num2str(subject') '_epoched.set'];
    epochedBaselineFileNameEEG = [num2str(subject') '_epoched_baseline.set'];
    epochedEEG                 =  pop_loadset('filepath', participantFolder ,'filename', epochedFileNameEEG);
    epochedEEG_baseline        =  pop_loadset('filepath', participantFolder ,'filename', epochedBaselineFileNameEEG);
    
    [erd_encoding_2_3, var_epoch_en, var_epoch_re] = WM_06_epochtheta(epochedEEG,epochedEEG_baseline);
    
    c_erd_encoding_2_3(Ci,:) = erd_encoding_2_3;
    c_var_epoch_en(:,:,Ci)   = var_epoch_en;
    c_var_epoch_re(:,:,Ci)   = var_epoch_re;

end

% save them

table_path = 'C:\Users\BERRAK\Documents\GitHub\WaterMazeProject\Results\Tables\AverageOverEloc';

save(fullfile(table_path,'p_erd_encoding_2_3.mat'), 'p_erd_encoding_2_3');
save(fullfile(table_path,'p_var_epoch_en.mat'), 'p_var_epoch_en');
save(fullfile(table_path,'p_var_epoch_re.mat'), 'p_var_epoch_re');
save(fullfile(table_path,'c_erd_encoding_2_3.mat'), 'c_erd_encoding_2_3');
save(fullfile(table_path,'c_var_epoch_en.mat'), 'c_var_epoch_en');
save(fullfile(table_path,'c_var_epoch_re.mat'), 'c_var_epoch_re');

% Third: Regression Graph
%-----------------------------------------------------------------------------

% WM_06_regression

%% STEP 07: Statistical Analysis

% WM_07_analysis

