% Source reconstruction from EEG data using FieldTrip toolbox
% Original by Dr Xi

% Quoted literally from slides:
% - There are two markers in the data that represents on and off.
% - The S1 marker means "on", meaning that the participant's hand was in
% either warm or cold water during that time.
% - The S2 marker means "off", meaning that it was waiting time or baseline
% time, and the participant's hand was not in water.

%% CHANGELOG
% 2020-05-19
%    Function to get times of events that define trials. 
%    Uses: create, edits such events.
% 2020-05-20
%    Rewritten hx_trialfun_general -> ea_trialfun_general. It now consider
%    the chunk from S1 to S2 triggers.

%% 0. WORKING DIR
% %
% % data directory
% dataDIR   = '../../HXIproj_data/';
% inDIR     = [ dataDIR, 'input/Peng' ];
% filePATH  = [ inDIR, '/waterpain1.vhdr' ];
% FTversion = '20200227'; % update if fieldtrip is changed
% 
% % FieldTrip directory+init
% addpath([ '../../fieldtrip-',FTversion ])
% ft_defaults    % initialization
% 
% % custom Fieldtrip functions by HXI
% addpath('../HXI_fieldtrip')
% 
% % specific segments: [prestim,poststim]
% prestim  = 0;
% poststim = 0;
% 
% %% 1. DATA LOAD
% %
% % FC/FIC data
% cfg = [];
% cfg.dataset            = filePATH; % path+name of CTF dataset  
% %cfg.trialfun           = 'hx_trialfun_general'; % start at trigger S1
% cfg.trialfun           = 'ea_trialfun_general'; % goes from S1 to S2
% cfg.trialdef.eventtype = 'Stimulus';
% cfg.trialdef.pre       = prestim;
% cfg.trialdef.post      = poststim;
% cfg = ft_definetrial(cfg);



%% DEPRECATED
%% 0. WORKING DIR
%
% data directory
dataDIR   = '../../HXIproj_data/';
inDIR     = [ dataDIR, 'input/Peng' ];
filePATH  = [ inDIR, '/waterpain1.vhdr' ];
FTversion = '20200227'; % update if fieldtrip is changed

% FieldTrip directory+init
addpath([ '../../fieldtrip-',FTversion ])
ft_defaults    % initialization

% custom Fieldtrip functions by HXI
addpath('../HXI_fieldtrip')

%% 1. DATA LOAD
%
% FC/FIC data
cfg = [];
cfg.dataset            = filePATH; % path+name of CTF dataset  
cfg.trialfun           = 'hx_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
% cfg.trialdef.pre       = prestim;
% cfg.trialdef.post      = poststim;
% cfg = ft_definetrial(cfg);

% read the header information and the events from the data
hdr   = ft_read_header(cfg.dataset);
event = struct2cell( ft_read_event(cfg.dataset) );
event(:,:,1) = [];

SampleFreq = hdr.Fs;

markers = cell2mat( event(2,1,:) );
S1 = markers(1,4,:) == '1';
S2 = markers(1,4,:) == '2';
S3 = markers(1,4,:) == '3';

S1 = cell2mat( event(3,1,S1) );
S2 = cell2mat( event(3,1,S2) );
S3 = cell2mat( event(3,1,S3) );

S1 = S1(:)';
S2 = S2(:)';
S3 = S3(:)';

plot( [S1 S2 S3]/SampleFreq, [S1*0+1, S2*0+2, S3*0+3], '.' )

%% 2. REQUESTED INFO
disp( 'Event start + end' )
