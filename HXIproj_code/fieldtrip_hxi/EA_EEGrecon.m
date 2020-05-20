% Source reconstruction from EEG data using FieldTrip toolbox
% Original by Dr Xi
% 
% Be careful with directory structure. Code is additionally sent to git.

%% CHANGELOG
% 2019-09-17
%    JC.EA started adding comments for his own project
%    FieldTrip changed to version 20190615
%    Changing to local routes
% 2020-01-20
%    Moved to MATLAB Drive for portability
% 2020-03-02
%    Updating details for presenting

%% 0. PARAMETERS
%
% data directory
dataDIR   = '../../../HXIproj_data/';
inDIR     = [ dataDIR, 'input/Peng' ];
filePATH  = [ inDIR, '/waterpain1.vhdr' ];

% FieldTrip directory+init
addpath('../../../fieldtrip-20200227') %updatable
ft_defaults    % initialization

% specific segments: [prestim,poststim]
prestim  = 0;
poststim = 3;

%% 1. DATA LOAD
%
% templates
load sourcespace_template;
load vol_template;
load elec_template;
load leadfield_template;

% FC/FIC data
cfg = [];
cfg.dataset            = filePATH; % path+name of CTF dataset  
cfg.trialfun           = 'hx_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.pre       = prestim;
cfg.trialdef.post      = poststim;
%cfg.trialdef.eventvalue = 9;   % trigger value for fully congruent (FC)
cfg = ft_definetrial(cfg);
cfg.channel = {'all'}; % read all MEG channels except MLP31 and MLO12

% use trials without artifacts (given)
cfg.trl([   2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],:) = []; %FC
%cfg.trl([1, 2,    4, 5, 6,    8, 9, 10,     12, 13],:) = []; % right cold

% preprocess
dataFC_LP = ft_preprocessing(cfg);

%% 2. VISUAL EXPLORATION
%
% regular plot
cfg = [];
cfg.viewmode   = 'butterfly';
cfg.continuous = 'no';
cfg.channel    = elec.label;

cfg.plotlabels ='yes'; 
ft_databrowser( cfg,dataFC_LP )
pause;

%% 3. AVERAGING + NOISE-COVARIANCE
cfg = [];
cfg.covariance = 'yes';
cfg.channel    = {'all'};
cfg.grad       = elec;

tlckFC  = ft_timelockanalysis( cfg,dataFC_LP );

%% 3. INVERSE SOLUTION
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

%% 4. Plot
%
cfg =[];
cfg.sourcemodel.pos    = leadfield.pos;
cfg.sourcemodel.inside = leadfield.inside';
sourcemodel = ft_prepare_sourcemodel(cfg);

picFC = sourceFC;
picFC.avg.pow = sourceFC.avg.pow(:,450);

cfg = [];
cfg.downsample = 2;
cfg.parameter  = 'pow';
sourceInter    = ft_sourceinterpolate(cfg, picFC, sourcemodel);

cfg  = [];
cfg.method       = 'cloud';
cfg.funparameter = 'pow';
ft_sourceplot(cfg,sourceInter);

cfg  = [];
cfg.method       = 'slice';
cfg.funparameter = 'pow';
ft_sourceplot(cfg,sourceInter);


%%
picFC = sourceFC;
%picFC.avg.pow = sourceFC.avg.pow(:,450);
picFC.avg.pow = sourceFC.avg.pow(:,450);

cfg =[];
cfg.sourcemodel.pos    = sourceFC.pos;
cfg.sourcemodel.inside = sourceFC.inside';
sourcemodel = ft_prepare_sourcemodel(cfg);

cfg  = [];
cfg.method       = 'surface';
cfg.funparameter = 'pow';
cfg.funcolorlim  = [min(picFC.avg.pow) max(picFC.avg.pow)];
ft_sourceplot( cfg, picFC );

cfg  = [];
cfg.method       = 'vertex';
cfg.funparameter = 'pow';
cfg.funcolorlim  = [min(picFC.avg.pow) max(picFC.avg.pow)];
ft_sourceplot( cfg, picFC );

%% DEPRECATED CODE - KEPT FOR EXPERIMENTATION
%cfg.grad       = elec;
%cfg.covariancewindow = ...
%   [-prestim poststim];
%   [-inf 0];                 %it will calculate the covariance matrix 
                             % on the timepoints that are  
                             % before the zero-time point in the trials
%tlckFC  = ft_timelockanalysis(cfg, dataFC_LP);

%sdFC  = hx_sourcedescriptives(cfg,sourceFC);
%cfg = [];
%cfg.maskparameter = 'pow';
%figure;
%ft_sourcemovie(cfg,sdFC);