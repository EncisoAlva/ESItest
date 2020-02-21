%%
clear all;
close all;
clc;

addpath(genpath(pwd));
ft_defaults;

%% Processing of functional data
% Preprocessing of MEG data

% 1. Reading the FC data
inputDir = '..\data\input';
outputDir = '..\data\output';
dirName = 'Subject01';
pathName = [inputDir, filesep, dirName];
prefix = 'Subject01';
suffix = '.ds';
fileName = [prefix, suffix];
fullName = [pathName, filesep, fileName];

% find the interesting segments of data
cfg = [];
cfg.dataset                 = fullName;       % name of CTF dataset  
cfg.trialdef.eventtype      = 'backpanel trigger';
cfg.trialdef.prestim        = 1;
cfg.trialdef.poststim       = 2;
cfg.trialdef.eventvalue     = 9;   % trigger value for fully congruent (FC)
cfg = ft_definetrial(cfg);            

% remove the trials that have artifacts from the trl
cfg.trl([2, 3, 4, 30, 39, 40, 41, 45, 46, 47, 51, 53, 59, 77, 85],:) = []; 

% preprocess the data
cfg.channel    = {'MEG', '-MLP31', '-MLO12'};       % read all MEG channels except MLP31 and MLO12
cfg.demean     = 'yes';
cfg.baselinewindow  = [-0.2 0];
cfg.lpfilter   = 'yes';                              % apply lowpass filter
cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

dataFC_LP = ft_preprocessing(cfg);
save dataFC_LP dataFC_LP;

% 2. Reading the FIC data
% find the interesting segments of data
cfg = [];
cfg.dataset                 = fullName;       % name of CTF dataset  
cfg.trialdef.eventtype      = 'backpanel trigger';
cfg.trialdef.prestim        = 1;
cfg.trialdef.poststim       = 2;
cfg.trialdef.eventvalue     = 3; % trigger value for fully incongruent (FIC)
cfg = ft_definetrial(cfg);            

% remove the trials that have artifacts from the trl
cfg.trl([15, 36, 39, 42, 43, 49, 50, 81, 82, 84],:) = []; 

% preprocess the data
cfg.channel    = {'MEG', '-MLP31', '-MLO12'};  % read all MEG channels except MLP31 and MLO12
cfg.demean     = 'yes';
cfg.baselinewindow  = [-0.2 0];
cfg.lpfilter   = 'yes';                              % apply lowpass filter
cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

dataFIC_LP = ft_preprocessing(cfg);   
save dataFIC_LP dataFIC_LP;

%% Averaging and noise-covariance estimation
% load dataFC_LP;
% load dataFIC_LP;
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = [-inf 0]; %it will calculate the covariance matrix 
                               % on the timepoints that are  
                               % before the zero-time point in the trials
tlckFC = ft_timelockanalysis(cfg, dataFC_LP);
tlckFIC = ft_timelockanalysis(cfg, dataFIC_LP);
save tlck tlckFC tlckFIC;

%% Forward solution
% load tlck;
load sourcespace;
load vol;

cfg = [];
cfg.grad = tlckFC.grad;                      % sensor positions
cfg.channel = {'MEG', '-MLP31', '-MLO12'};   % the used channels
cfg.grid.pos = sourcespace.pnt;              % source points
cfg.grid.inside = 1:size(sourcespace.pnt,1); % all source points are inside of the brain
cfg.vol = vol;                               % volume conduction model
leadfield = ft_prepare_leadfield(cfg);

save leadfield leadfield;

%% Inverse solution
% load tlck;
% load leadfield;
% load vol;

cfg        = [];
cfg.method = 'mne';
cfg.grid   = leadfield;
cfg.vol    = vol;
cfg.mne.prewhiten = 'yes';
cfg.mne.lambda    = 3;
cfg.mne.scalesourcecov = 'yes';
sourceFC  = ft_sourceanalysis(cfg,tlckFC);
sourceFIC = ft_sourceanalysis(cfg, tlckFIC);

save source sourceFC sourceFIC;

%% Visualization
% load source;
load sourcespace;

bnd.pnt = sourcespace.pnt;
bnd.tri = sourcespace.tri;
m=sourceFIC.avg.pow(:,450); % plotting the result at the 450th time-point that is 
                         % 500 ms after the zero time-point
ft_plot_mesh(bnd, 'vertexcolor', m);

% show the diffenrence of the two conditions
cfg = [];
cfg.projectmom = 'yes';
sdFC = ft_sourcedescriptives(cfg,sourceFC);
sdFIC = ft_sourcedescriptives(cfg, sourceFIC);

sdDIFF = sdFIC;
sdDIFF.avg.pow = sdFIC.avg.pow - sdFC.avg.pow;
sdDIFF.tri = sourcespace.tri;

save sd sdFC sdFIC sdDIFF;

cfg = [];
cfg.mask = 'avg.pow';
figure;
ft_sourcemovie(cfg,sdDIFF);
















