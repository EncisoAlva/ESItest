% Source reconstruction from EEG data using FieldTrip toolbox
% Original by Dr Xi
% 
% Code is additionally sent to GitHub.

%% CHANGELOG
% 2019-09-17
%    JC.EA started adding comments for his own project.
%    FieldTrip changed to version 20190615.
%    Changing to local routes.
% 2020-01-20
%    Moved to MATLAB Drive for portability.
% 2020-03-02
%    Updating details for presenting.
%    FieldTrip changed to version 20200227.
% 2020-04-03
%    Fully online.

%% 0. WORKING DIR
%
% data directory
dataDIR   = '../../HXIproj_data/';
inDIR     = [ dataDIR, 'input/Peng' ];
filePATH  = [ inDIR, '/waterpain1.vhdr' ];
FTversion = '20200227'; % update if fieldtrip is changed

% templates
addpath('../templates')

% FieldTrip directory+init
addpath([ '../../fieldtrip-',FTversion ])
ft_defaults    % initialization

% custom Fieldtrip functions by HXI
addpath('../HXI_fieldtrip')

% specific segments: [prestim,poststim]
prestim  = 6;
poststim = 20;

%% 1. DATA LOAD
%
% DEPRECATED: old templates
load sourcespace_template;
load vol_template;
load elec_template;
load leadfield_template;

% templates
%addpath([ '../../fieldtrip-',FTversion,'/template/sourcemodel' ])
%load standard_sourcemodel3d5mm.mat

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
%cfg.trl([   2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],:) = []; %FC
%cfg.trl([1, 2,    4, 5, 6,    8, 9, 10,     12, 13],:) = []; % right cold

%CHOSEN_TRIAL = 3;
cfg.trl( setdiff(1:13,CHOSEN_TRIAL) ,:) = []; %FC

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

%subplot(7,4,[1 2 3 4])
ft_databrowser( cfg,dataFC_LP )

set(gcf, 'PaperUnits', 'inches');
x_width=8;
y_width=3;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
saveas(gcf,['line',num2str(CHOSEN_TRIAL,'%02d'),'.png'])
close all

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
picFC  = sourceFC;

cfg =[];
cfg.sourcemodel.pos    = sourceFC.pos;
cfg.sourcemodel.inside = sourceFC.inside';
sourcemodel = ft_prepare_sourcemodel(cfg);


CARRIER = zeros(8196,24);

for Snap = 0:23
TimeWin = max(1,Snap*1000):(Snap+3)*1000;
CARRIER(:,Snap+1) = mean( sourceFC.avg.pow(:,TimeWin), 2 );
end

% atypical values are removed for better visualization
IQ     = iqr(CARRIER(:));
MinZ = quantile(CARRIER(:),0.25) - 1.5*IQ;
MaxZ = quantile(CARRIER(:),0.75) + 1.5*IQ;

MinPow = max( min(CARRIER(:)), MinZ );
MaxPow = min( max(CARRIER(:)), MaxZ );

cfg  = [];
cfg.method       = 'surface';
cfg.funparameter = 'pow';
cfg.funcolorlim  = [MinPow MaxPow];

for Snap = 0:23
picFC.avg.pow = CARRIER(:,Snap+1);

%figure()
ft_sourceplot( cfg, picFC );

set(gcf, 'PaperUnits', 'inches');
x_width=2*4/3;
y_width=2*4/3;
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
saveas(gcf,['brn',num2str(CHOSEN_TRIAL,'%02d'),'_',...
    num2str(Snap,'%02d'),'.png'])
close all
end
