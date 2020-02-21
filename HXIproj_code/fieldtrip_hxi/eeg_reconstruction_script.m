clc;
clear all;
close all;

%addpath('C:/MyProject/fieldtrip-20130901');
addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

prestim = -23;
poststim = 26;

%% Processing of functional data
% Preprocessing of MEG data

% 1. Reading the FC data
inputDir = '..\data\input';
outputDir = '..\data\output';
dirName = 'Peng';
pathName = [inputDir, filesep, dirName];
prefix = 'waterpain1';
suffix = '.vhdr';
fileName = [prefix, suffix];
fullName = [pathName, filesep, fileName];

% find the interesting segments of data
cfg = [];
cfg.dataset                 = fullName;       % name of CTF dataset  
cfg.trialdef.eventtype      = 'Stimulus';
cfg.trialfun                = 'hx_trialfun_general';
cfg.trialdef.pre        = prestim;
cfg.trialdef.post       = poststim;
%cfg.trialdef.eventvalue     = 9;   % trigger value for fully congruent (FC)
cfg = ft_definetrial(cfg);            

% remove the trials that have artifacts from the trl
% cfg.trl([1, 3, 4, 5, 7, 8, 9, 11, 12, 13],:) = []; 
cfg.trl([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],:) = []; 

% preprocess the data
cfg.channel    = {'all'};       % read all MEG channels except MLP31 and MLO12
% cfg.demean     = 'yes';
% cfg.baselinewindow  = [-0.2 0];
% cfg.lpfilter   = 'yes';                              % apply lowpass filter
% cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

dataFC_LP = ft_preprocessing(cfg);
%save dataFC_LP dataFC_LP;

%% 2. Reading the FIC data
% find the interesting segments of data
cfg = [];
cfg.dataset                 = fullName;       % name of CTF dataset  
cfg.trialdef.eventtype      = 'Stimulus';
cfg.trialfun                = 'hx_trialfun_general';
cfg.trialdef.pre        = prestim;
cfg.trialdef.post       = poststim;
%cfg.trialdef.eventvalue     = 3; % trigger value for fully incongruent (FIC)
cfg = ft_definetrial(cfg);            

% remove the trials that have artifacts from the trl
 cfg.trl([1, 2, 4, 5, 6, 8, 9, 10, 12, 13],:) = []; 
%cfg.trl([1, 3, 4, 5, 7, 8, 9, 11, 12, 13],:) = []; 

% preprocess the data
cfg.channel    = {'all'};  % read all MEG channels except MLP31 and MLO12
% cfg.demean     = 'yes';
% cfg.baselinewindow  = [-0.2 0];
% cfg.lpfilter   = 'yes';                              % apply lowpass filter
% cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

dataFIC_LP = ft_preprocessing(cfg);   
%save dataFIC_LP dataFIC_LP;

%% Averaging and noise-covariance estimation
% load dataFC_LP;
% load dataFIC_LP;
load elec_haley elec;

cfg = [];
cfg.covariance = 'yes';
cfg.channel={'all'};
cfg.grad=elec;
%cfg.covariancewindow = [-prestim poststim];%[-inf 0]; %it will calculate the covariance matrix 
                               % on the timepoints that are  
                               % before the zero-time point in the trials
tlckFC = ft_timelockanalysis(cfg, dataFC_LP);
tlckFIC = ft_timelockanalysis(cfg, dataFIC_LP);
%save tlck tlckFC tlckFIC;

%% Forward solution
% load tlck;
load C:\MyProject\data\input\Peiying\sub1-2013-12-19\sub1_artifact_correction\sourcespace;
load C:\MyProject\data\input\Peiying\sub1-2013-12-19\sub1_artifact_correction\vol;
%load template_vol;
% sourcespace = vol.bnd(3);

% cfg = [];
% cfg.grad = elec;                      % sensor positions
% cfg.channel = {'all'};   % the used channels
% cfg.grid.pos = sourcespace.pnt;              % source points
% cfg.grid.inside = 1:size(sourcespace.pnt,1); % all source points are inside of the brain
% cfg.vol = vol;                               % volume conduction model
% leadfield = ft_prepare_leadfield(cfg);
% 
% save leadfield leadfield;

%% Inverse solution
% load tlck;
load leadfield;

% update channel label
% filename = 'C:\MyProject\data\input\electrodes\electrode_layout_haley.txt';
% label_old = elec.label;
% label_new = hx_label2number(label_old,filename);
% elec.label = label_new;
% elec.cfg.elec.label = label_new;

cfg        = [];
cfg.method = 'mne';
cfg.channel={'all'};
cfg.grad   = elec;
cfg.grid   = leadfield;
cfg.vol    = vol;
cfg.mne.prewhiten = 'yes';
cfg.mne.lambda    = 3;
cfg.mne.scalesourcecov = 'yes';
sourceFC  = ft_sourceanalysis(cfg,tlckFC);
sourceFIC = ft_sourceanalysis(cfg, tlckFIC);

%save source sourceFC sourceFIC;

%% Visualization
% load source;
% load sourcespace;

% bnd.pnt = sourcespace.pnt;
% bnd.tri = sourcespace.tri;
% m=sourceFIC.avg.pow(:,450); % plotting the result at the 450th time-point that is 
%                          % 500 ms after the zero time-point
% ft_plot_mesh(bnd, 'vertexcolor', m);

%%
% show the diffenrence of the two conditions
cfg = [];
%cfg.projectmom = 'yes';
cfg.baselinewindow = [-prestim poststim];
sdFC = hx_sourcedescriptives(cfg,sourceFC);
sdFIC = hx_sourcedescriptives(cfg, sourceFIC);

sdDIFF = sdFIC;
sdDIFF.avg.pow = abs(sdFIC.avg.pow - sdFC.avg.pow);
sdDIFF.tri = sourcespace.tri;

%save sd sdFC sdFIC sdDIFF;

%%
cfg = [];
cfg.maskparameter = 'pow';
figure;
ft_sourcemovie(cfg,sdDIFF);


