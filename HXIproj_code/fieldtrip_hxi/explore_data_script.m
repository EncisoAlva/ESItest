%explore_data_script.m

clc;
clear all;
close all;

addpath('C:/MyProject/fieldtrip-20130901');
ft_defaults;

%%
load ../data/input/Wang/painEEG_clean_1_40Hz;
% myChannel = {'18','19','51','52','53'};
myChannel = {'all'};

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
cfg.trialdef.pre        = 10;
cfg.trialdef.post       = 70;
%cfg.trialdef.eventvalue     = 9;   % trigger value for fully congruent (FC)
cfg = ft_definetrial(cfg); 

%%
% remove the trials that have artifacts from the trl
% cfg.trl([1, 3, 4, 5, 7, 8, 9, 11, 12, 13],:) = []; 
cfg.trl([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],:) = []; 

% preprocess the data
cfg.channel    = myChannel;       % read all MEG channels except MLP31 and MLO12
% cfg.demean     = 'yes';
% cfg.baselinewindow  = [-0.2 0];
% cfg.lpfilter   = 'yes';                              % apply lowpass filter
% cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

dataFC_LP = ft_preprocessing(cfg);

% update trials with lowpass data
dataFC_LP = hx_update_trial(dataFC_LP, EEGclean_1_40Hz);

save dataFC_LP dataFC_LP;

%% 2. Reading the FIC data
% find the interesting segments of data
cfg = [];
cfg.dataset                 = fullName;       % name of CTF dataset  
cfg.trialdef.eventtype      = 'Stimulus';
cfg.trialfun                = 'hx_trialfun_general';
cfg.trialdef.pre        = 10;
cfg.trialdef.post       = 70;
%cfg.trialdef.eventvalue     = 3; % trigger value for fully incongruent (FIC)
cfg = ft_definetrial(cfg);            

% remove the trials that have artifacts from the trl
% cfg.trl([1, 2, 4, 5, 6, 8, 9, 10, 12, 13],:) = []; 
%cfg.trl([1, 3, 4, 5, 7, 8, 9, 11, 12, 13],:) = []; %right warm
cfg.trl([1, 2, 4, 5, 6, 7,8, 9, 10,11, 12, 13],:) = []; %right cold

% preprocess the data
cfg.channel    = myChannel;  % read all MEG channels except MLP31 and MLO12
% cfg.demean     = 'yes';
% cfg.baselinewindow  = [-0.2 0];
% cfg.lpfilter   = 'yes';                              % apply lowpass filter
% cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

dataFIC_LP = ft_preprocessing(cfg);   

% update trials with lowpass data
dataFIC_LP = hx_update_trial(dataFIC_LP, EEGclean_1_40Hz);

save dataFIC_LP dataFIC_LP;

%% Averaging and noise-covariance estimation
load dataFC_LP;
load dataFIC_LP;
load elec_haley elec;

cfg = [];
cfg.covariance = 'yes';
cfg.channel=myChannel;
cfg.grad=elec;
cfg.covariancewindow = [-inf 0]; %it will calculate the covariance matrix 
                               % on the timepoints that are  
                               % before the zero-time point in the trials
tlckFC = ft_timelockanalysis(cfg, dataFC_LP);
tlckFIC = ft_timelockanalysis(cfg, dataFIC_LP);
save tlck tlckFC tlckFIC;

%% Forward solution
% load tlck;
load C:\MyProject\data\input\Peiying\sub1-2013-12-19\sub1_artifact_correction\sourcespace;
load C:\MyProject\data\input\Peiying\sub1-2013-12-19\sub1_artifact_correction\vol;


cfg = [];
cfg.grad = elec;                      % sensor positions
cfg.channel = myChannel;   % the used channels
cfg.grid.pos = sourcespace.pnt;              % source points
cfg.grid.inside = 1:size(sourcespace.pnt,1); % all source points are inside of the brain
cfg.vol = vol;                               % volume conduction model
leadfield = ft_prepare_leadfield(cfg);

save leadfield leadfield;

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
cfg.channel=myChannel;
cfg.grad   = elec;
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
% load sourcespace;

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
sdDIFF.avg.pow = sdFIC.avg.pow - (sdFC.avg.pow-sdFC.avg.pow);
sdDIFF.tri = sourcespace.tri;

save sd sdFC sdFIC sdDIFF;

%%
cfg = [];
cfg.mask = 'avg.pow';
figure;
ft_sourcemovie(cfg,sdDIFF);

%% topoplot
% load painEEG_clean_1_40Hz;
load dataFC_LP;

cfg = [];
cfg.xlim = [0.9 1.3];
cfg.ylim = [15 20];
cfg.zlim = [-1e-27 1e-27];
cfg.baseline = [-0.5 -0.1];
cfg.baselinetype = 'absolute';
cfg.layout = 'easycap64ch-avg.lay';

%Options specific for to using topoplot.m
cfg.gridscale = 300;                  
cfg.style = 'straight';               
cfg.marker = 'labels';                
figure; ft_topoplotTFR(cfg,dataFC_LP);

%load TFRhann

%%
load GA_FC;

cfg = [];                            
cfg.xlim = [0.3 0.5];                
cfg.zlim = [0 6e-14];                
cfg.layout = 'CTF151.lay';            
figure; ft_topoplotER(cfg,GA_FC); colorbar;

%% baseline
load dataFC_LP;

cfg = [];                            
% cfg.xlim = [0.3 0.5];                
% cfg.zlim = [0 6e-14];                
cfg.layout = 'easycapM1_haley_pain.lay';            
figure; ft_topoplotER(cfg,dataFC_LP); colorbar;

%% right cold
load dataFIC_LP;

cfg = [];                            
% cfg.xlim = [0.3 0.5];                
% cfg.zlim = [0 6e-14];    
cfg.layout = 'easycapM1_haley_pain.lay';            
figure; ft_topoplotER(cfg,dataFIC_LP); colorbar;