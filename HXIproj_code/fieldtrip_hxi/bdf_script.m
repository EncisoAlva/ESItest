%%
% clear all;
% close all;
% clc;

% addpath(genpath(pwd));
% ft_defaults;
%addpath('../fieldtrip-20130901');
addpath('../fieldtrip-20150911');
ft_defaults

%% data reading
% pathName = 'C:\MyProject\data\input\Liu_Ola\';
% fileName = 'brandon-resting.bdf';
pathName = 'C:\MyProject\data\input\multimodalSTUDY\subject1\';
fileName = 'vikas.bdf';
fullName = [pathName, fileName];

hdr = ft_read_header(fullName);
dat = ft_read_data(fullName); % nChan x nSamples
event = ft_read_event(fullName);

%%
cfg = [];
cfg.trialdef.eventtype='SyncStatus'; %'New Segment' 'Response' 'SyncStatus' 
cfg.trialdef.eventvalue='Sync On'; % 'R128', 'Sync On'
cfg.trialfun     = 'ft_trialfun_general';
%ft_trialfun_general
cfg.headerfile   = fullName;

cfg.trialdef.triallength = 100%654; %duration in seconds (can be Inf)
cfg.trialdef.ntrials     = 1%500; %number of trials sbu1:506 sub4 207

cfg = ft_definetrial(cfg);

cfg.method='trial'; %'channel'
cfg.demean = 'yes';

%This function will call ft_read_data
%ft_read_data will call read_brainvision_eeg
%    fseek(fid, hdr.NumberOfChannels*samplesize*(begsample-1), 'cof');
%    dat = fread(fid, [hdr.NumberOfChannels, (endsample-begsample+1)],
%    sampletype);  This will read in a 32*10000 matrix in column order
dataPRE = ft_preprocessing(cfg);
save dataPRE dataPRE

%%
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = 'all'; %[-inf 0]; %it will calculate the covariance matrix 
                                   % on the timepoints that are  
                                   % before the zero-time point in the trials
cfg.trials = 1%351:351; %Average over these trials
tlck = ft_timelockanalysis(cfg, dataPRE);
save tlck tlck;

%%
%-----------------Forward solution----------------------
load sourcespace;
load vol;
load elec;
%%
cfg = [];
%elec.label   % cell-array of length N with the label of each channel
%elec.elecpos % Mx3 matrix with the cartesian coordinates of each electrode
%elec.chanpos % Nx3 matrix with the cartesian coordinates of each channel
%http://fieldtrip.fcdonders.nl/faq/how_are_electrodes_magnetometers_or_gradiometers_described
%Note that there is typically a one-to-one match between electrodes and channels, 
%but in principle channels and electrodes can refer to different entities. 
%In the context of EEG, one may consider a setup containing bipolar derivations, 
%in which each 'channel' represents the voltage difference between a pair of electrodes. 
%Consequently, the number of channels N then is different from the number of electrodes M. 
%An additional field is needed in the elec-structure
%elec.tra  % NxM matrix with the weight of each electrode into each channel 
%to tell FieldTrip how to combine the electrodes into channels. This array
%can be stored as a sparse array and it also allows to set the position of the reference electrode 
%in unipolar recordings. In case elec.tra is not provided, the forward and inverse calculations 
%will be performed assuming an average reference over all electrodes.

%cfg.grad = read_elecrodes_position('BrainCapMR32Ch.txt'); % tlckFC.grad;
cfg.elec = elec; %!!! see file elecrodes_positions.m for sensor positions (we need alignment)

%cfg.elec.tra = sparse(size(cfg.elec.chanpos,1), size(cfg.elec.elecpos,1) );

%for i=1:size(cfg.elec.elecpos,1)
%    cfg.elec.tra(i,i)=1;
%end

%Hongguang: there are only 31 channels, change 'all' to {'all','-ECG'}
cfg.channel = {'all','-ECG'};   % the used channels
cfg.sourceunits = 'mm';
cfg.grid.pos = sourcespace.pnt;              % source points
cfg.grid.inside = 1:size(sourcespace.pnt,1); % all source points are inside of the brain
cfg.vol = vol;                               % volume conduction model
leadfield = ft_prepare_leadfield(cfg);

save leadfield leadfield;

%%
%-------------------------Inverse solution-----------------------
load tlck;
load sourcespace;
load leadfield;
load vol;
load elec;
%%
cfg        = [];
cfg.method = 'mne';%mne
cfg.grid   = leadfield;
cfg.vol    = vol;
cfg.mne.prewhiten = 'yes';
cfg.mne.lambda    = 1e-5;
cfg.mne.scalesourcecov = 'yes';
%cfg.elec = read_elecrodes_position('BrainCapMR32Ch.txt'); % sensor positions
cfg.elec = elec; %see file elecrodes_positions.m for sensor positions (we need alignment)

%Error in ==> minimumnormestimate at 226
%mom = w * dat; 修改文件BrainCapMR32Ch.txt，保证channel名称和tlck一致
source  = ft_sourceanalysis(cfg,tlck);

%save -v7.3 source source;

%%
%-------------------------------Visualization------------------------
%load source;
load sourcespace;
%%
bnd.pnt = sourcespace.pnt;
bnd.tri = sourcespace.tri;
m=source.avg.pow(:,450); % plotting the result at the 450th time-point that is 
                         % 500 ms after the zero time-point
%ft_plot_vol(vol, 'facecolor', 'none');alpha 0.5; %comment by hxi
figure;
ft_plot_mesh(bnd, 'vertexcolor', m);

%% hxi: see difference
cfg = [];
cfg.projectmom = 'yes';
sdFC = ft_sourcedescriptives(cfg,source);
sdFIC = ft_sourcedescriptives(cfg, source);

sdDIFF = sdFIC;
sdDIFF.avg.pow = sdFIC.avg.pow - sdFC.avg.pow;
sdDIFF.tri = sourcespace.tri;

save sd sdFC sdFIC sdDIFF;

cfg = [];
cfg.mask = 'avg.pow';
ft_sourcemovie(cfg,sdDIFF);

%%
cfg = [];
cfg.layout = 'biosemi128.lay'
ft_layoutplot(cfg)
