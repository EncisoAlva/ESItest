% Source reconstruction from EEG data using FieldTrip toolbox
% Original by Dr Xi

%% CHANGELOG
% 2019-09-17
%   JC.EA started adding comments for his own project
%   FieldTrip changed to version 20190615
%   Changing to local routes

%% fresh start
clc;
clear all;
close all;

%% FieldTrip
cd ../fieldtrip-20190615
addpath(pwd);
cd ../fieldtrip_hxi

ft_defaults    % initialization

%% Load data
load sourcespace_template;
load vol_template;
load elec_template;
load leadfield_template;

%% Processing of functional data

%% 0. Working dirs
cd ../../data
inputDir  = [ pwd, filesep, 'input'];
outputDir = [ pwd, filesep, 'output'];
cd ../code/fieldtrip_hxi
dirName   = 'Peng';
pathName  = [inputDir, '/', dirName];
prefix    = 'waterpain1';
suffix    = '.vhdr';
fileName  = [prefix, suffix];
fullName  = [pathName, '/', fileName];

% Select segments
prestim  = 0;
poststim = -prestim + 3;

%% 1. Reading the FC data
cfg = [];
cfg.dataset            = fullName;       % name of CTF dataset  
cfg.trialfun           = 'hx_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.pre       = prestim;
cfg.trialdef.post      = poststim;
%cfg.trialdef.eventvalue = 9;   % trigger value for fully congruent (FC)
cfg = ft_definetrial(cfg);
cfg.channel = {'all'}; % read all MEG channels except MLP31 and MLO12

% Remove trials with artifacts
cfg.trl([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],:) = []; 

% Preprocess
dataFC_LP = ft_preprocessing(cfg);

%% 2. Reading the FIC data (look the trials)
cfg = [];
cfg.dataset            = fullName;       % name of CTF dataset  
cfg.trialfun           = 'hx_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.pre       = prestim;
cfg.trialdef.post      = poststim;
%cfg.trialdef.eventvalue = 3; % trigger value for fully incongruent (FIC)
cfg = ft_definetrial(cfg);            
cfg.channel = {'all'};  % read all MEG channels except MLP31 and MLO12

% Remove trials with artifacts
cfg.trl([1, 2, 4, 5, 6, 8, 9, 10, 12, 13],:) = []; % right cold

% Preprocess
% cfg.demean         = 'yes';
% cfg.baselinewindow = [-0.2 0];
% cfg.lpfilter       = 'yes';    % apply lowpass filter
% cfg.lpfreq         = 35;       % lowpass at 35 Hz.
dataFIC_LP = ft_preprocessing(cfg); 

%% 3. Averaging and noise-covariance estimation
cfg = [];
cfg.covariance = 'yes';
cfg.channel    = {'all'};
cfg.grad       = elec;
%cfg.covariancewindow = ...
%   [-prestim poststim];
%   [-inf 0];                 %it will calculate the covariance matrix 
                             % on the timepoints that are  
                             % before the zero-time point in the trials
tlckFC  = ft_timelockanalysis(cfg, dataFC_LP);
tlckFIC = ft_timelockanalysis(cfg, dataFIC_LP);

%% 4. Inverse solution
cfg = [];
cfg.method  = 'mne';
cfg.channel = {'all'};
cfg.grad    = elec;
cfg.grid    = leadfield;
cfg.vol     = vol;
cfg.mne.prewhiten      = 'yes';
cfg.mne.lambda         = 3;
cfg.mne.scalesourcecov = 'yes';
cfg.keepleadfield      = 'yes';

sourceFC  = ft_sourceanalysis(cfg, tlckFC);
sourceFIC = ft_sourceanalysis(cfg, tlckFIC);

%% 5. Plot
% m=sourceFIC.avg.pow(:,450); % plotting the result at the 450th time-point that is 
%                          % 500 ms after the zero time-point
% ft_plot_mesh(bnd, 'vertexcolor', m);

%% XXX 5. Plot
picFC = sourceFC;
picFC.avg.pow = sourceFC.avg.pow(:,450);

cfg =[];
cfg.sourcemodel.pos    = leadfield.pos;
cfg.sourcemodel.inside = leadfield.inside';
sourcemodel = ft_prepare_sourcemodel(cfg);

cfg            = [];
cfg.downsample = 2;
cfg.parameter  = 'pow';
sourceInter    = ft_sourceinterpolate(cfg, picFC, sourcemodel);

cfg              = [];
cfg.method       = 'surface';
cfg.funparameter = 'pow';
figure
ft_sourceplot(cfg,sourceInter);

%ft_plot_mesh(sourcespace.pnt, 'vertexcolor', sourceFC.avg.pow(:,450));


%% Differences between conditions
cfg = [];
%cfg.projectmom = 'yes';
if prestim <= 0
    cfg.baselinewindow = [-prestim poststim];
else
    cfg.baselinewindow = [-inf 0];
end
sdFC  = hx_sourcedescriptives(cfg,sourceFC);
sdFIC = hx_sourcedescriptives(cfg, sourceFIC);

sdDIFF         = sdFIC;
sdDIFF.avg.pow = sdFIC.avg.pow - sdFC.avg.pow;
sdDIFF.tri     = sourcespace.tri;

%% Plot average in big region
% figure;
% mid1 =6000;
% mid2 =7500;
% signal = abs(sdDIFF.avg.pow(mid1:mid2,:));
% signal_average = mean(signal,1);
% plot(signal_average);
% title('Activities at left middle part');

