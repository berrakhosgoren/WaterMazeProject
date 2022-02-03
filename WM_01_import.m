%% 01. IMPORTING FILES

%% configure Matlab paths 

if strcmp(pwd,'P:\Berrak_Hosgoren\WM_analysis_channel_level')
    dataFolder = 'P:\Berrak_Hosgoren\WM_data\'; 
else
    dataFolder = 'C:\Users\BERRAK\Desktop\BPNLab\Watermaze\Data\';
end

eeglab;
ft_defaults
ftPath = fileparts(which('ft_defaults'));
addpath(fullfile(ftPath, 'external','xdf')); 

% check 
which bemobil_xdf2bids 
which load_xdf

%% load .xdf data to check what is in there
% You can skip this if you already check for the rigid body names

streamNr = 2; 
eegStreamNr = 5; 

streams = load_xdf(fullfile(dataFolder, '\0_source-data\81001\81001_VR.xdf'));
streamnames     = cellfun(@(x) x.info.name, streams, 'UniformOutput', 0)';
channelnames    = cellfun(@(x) x.label, streams{streamNr}.info.desc.channels.channel, 'UniformOutput', 0)';

%% Basic bemobil_config fields

bemobil_config.study_folder             = dataFolder;
bemobil_config.filename_prefix          = '';
bemobil_config.source_data_folder       = '0_source-data\';
bemobil_config.bids_data_folder         = '1_BIDS-data\';
bemobil_config.session_names            = {'VR','desktop'};                         
% this corresponds to session label (example:{'VR', 'desktop'} if multisession)
bemobil_config.channel_locations_filename = 'eloc.elc';                             
% provide one when there is an eloc file present 

% these streams should be processed as rigid body streams containing 3 dof position and 3 dof orientation data (e.g. derivatives and filters applied)
bemobil_config.rigidbody_streams        = {'LeftFoot','Torso','PlayerTransform','PlayerTransfom','RightFoot'};
bemobil_config.bids_rbsessions          = [1,1,1,1,1 ; 0,0,1,1,0]; 
                                        

bemobil_config.bids_eeg_keyword         = 'BrainVision';                    % marker streams also contain these strings. However, only the continuous stream is imported
bemobil_config.bids_task_label          = 'watermaze';                        % task label in bids file 

bemobil_config.event_streams = 'ExperimentMarkerStream';

% custom function names - customization recommended for data sets that have
%                         an 'unconventional' naming scheme for motion channels
bemobil_config.bids_motionconvert_custom    = 'WM_bids_motionconvert';
bemobil_config.bids_parsemarkers_custom     = [];


%% xdf to Bids   

% change numarical IDs

numericalIDs                            = 82010;

bemobil_xdf2bids(bemobil_config, numericalIDs)


% Bids to Set  

% change numerical IDs

bemobil_config.study_folder             = dataFolder;
bemobil_config.raw_EEGLAB_data_folder   = '2_raw-EEGLAB\';
bemobil_config.session_names            = {'VR','desktop'}; 
bemobil_config.bids_task_label          = 'watermaze';
bemobil_config.resample_freq            = 250; 

numericalIDs                            = 82010;
bemobil_bids2set(bemobil_config, numericalIDs)
