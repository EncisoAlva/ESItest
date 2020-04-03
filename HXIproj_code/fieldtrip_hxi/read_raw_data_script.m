% read_raw_data_script.m
%
% http://fieldtrip.fcdonders.nl/example/getting_started_with_reading_raw_eeg_or_meg_data
%
% Getting started with reading raw EEG or MEG data In FieldTrip you first 
% have to define the segments of data in which you are interested, i.e. 
% the “trials”. That is done using the DEFINETRIAL function. You can use 
% the DEFINETRIAL function also to show a summary of all events on your data file:

%% Add paths
addpath(genpath(pwd));

%% Find intertesting events
cfg = [];
cfg.dataset = 'ArtifactMEG.ds';
cfg.trialdef.eventtype  = '?'; % let the code find the interesting event for you
ft_definetrial(cfg); % no output variable neccessary here, just look at the output in the Matlab screen

%% Define interesting events
% If you accept the findings by code, you need to define them.
cfg.trialdef.eventtype = 'trial';
cfg = ft_definetrial(cfg); % now you do want to use an output variable for definetrial, since you need its output

%% Artifact detection
% using the ARTIFACT_xxx functions (where xxx is for example EOG) and the REJECTARTIFACT function.

%% Preprocessing
raw_data = ft_preprocessing(cfg)

%% -------------The following is another example-----------------



%% Find intertesting events
cfg = [];
cfg.dataset = 'Subject01.ds';
cfg.trialdef.eventtype  = '?';
ft_definetrial(cfg); % no output, just look at screen

%% Define interesting events
% If you accept the findings by code, you need to define them.
cfg.trialdef.eventtype  = 'backpanel trigger';
cfg.trialdef.eventvalue = 1; %trigger value
cfg.trialdef.prestim    = 0.2; %pre-trigger duration
cfg.trialdef.poststim   = 0.6; %post-trigger duration
cfg = ft_definetrial(cfg); % now remember the output

%% Artifact detection
% using the ARTIFACT_xxx functions (where xxx is for example EOG) and the REJECTARTIFACT function.

%% Preprocessing
data_raw = ft_preprocessing(cfg)
