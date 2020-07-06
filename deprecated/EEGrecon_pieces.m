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
% 2020-05-27
%    Using templates compatible with an atlas.
% 2020-06-11
%    Now this code is deprecated. Refer to script_eeg_zones.

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

% specific segments: [-prestim,poststim] with 0 at stimulus
prestim  = 4;
poststim = 6;

%% 1. DATA LOAD
%
% templates given by HX
load vol_template;
load elec_template;
load leadfield_template;

% MRI template from FieldTrip
addpath([ '../../FT_template/headmodel' ])
load standard_mri
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

CHOSEN_TRIAL = 3;
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
ft_databrowser( cfg,dataFC_LP )

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

CARRIER = zeros(8196,9);

for Snap = 0:8
TimeWin = max(1,Snap*1000):(Snap+2)*1000;
CARRIER(:,Snap+1) = mean( sourceFC.avg.pow(:,TimeWin), 2 );
end

% atypical values are removed for better visualization
IQ     = iqr(CARRIER(:));
MinZ = quantile(CARRIER(:),0.25) - 1.5*IQ;
MaxZ = quantile(CARRIER(:),0.75) + 1.5*IQ;

MinPow = max( min(CARRIER(:)), MinZ );
MaxPow = min( max(CARRIER(:)), MaxZ );

% cfg  = [];
% cfg.method       = 'surface';
% cfg.funparameter = 'pow';
% cfg.funcolorlim  = [MinPow MaxPow];
% 
% %for Snap = 0:8
% Snap = 0;
% picFC.avg.pow = CARRIER(:,Snap+1);
% ft_sourceplot( cfg, picFC );
% 
% % set(gcf, 'PaperUnits', 'inches');
% % x_width=2*4/3;
% % y_width=2*4/3;
% % set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
% % saveas(gcf,['brn',num2str(CHOSEN_TRIAL,'%02d'),'_',...
% %     num2str(Snap,'%02d'),'.png'])
% % close all
% %end

%% TEMPLATE MRI FOR VISUALIZATION
load standard_mri

mri = ft_volumereslice([], mri);

% cfg = [];
% cfg.method        = 'fiducial';
% cfg.fiducial.nas = elec.cfg.template{1}.chanpos(1,:);
% cfg.fiducial.lpa = elec.cfg.template{1}.chanpos(2,:);
% cfg.fiducial.rpa = elec.cfg.template{1}.chanpos(3,:);
% [mri] = ft_volumerealign(cfg,mri);

k = vol.bnd;
vol.pos = k(1).pnt;
cfg = [];
cfg.method                = 'headshape';
cfg.headshape.headshape   = vol;
cfg.headshape.interactive = 'yes';
cfg.headshape.icp         = 'no';
[mri] = ft_volumerealign(cfg,mri);

mri = ft_volumereslice([], mri);

ft_sourceplot([],mri)

picFC  = sourceFC;

% 
% cfg =[];
% cfg.method             = 'basedonpos';
% cfg.sourcemodel.pos    = sourceFC.pos;
% cfg.sourcemodel.inside = sourceFC.inside';
% sourcemodel = ft_prepare_sourcemodel(cfg);
% 
% cfg = [];

%sourceFC.units = 'dm';

%for Snap = 0:8
Snap = 0;
picFC.avg.pow = CARRIER(:,Snap+1);

cfg            = [];
cfg.downsample = 2;
cfg.parameter  = 'pow';
sourceMRI  = ft_sourceinterpolate(cfg, picFC , mri);
%sourceMRI  = ft_sourceinterpolate(cfg, picFC , sourcemodel);

cfg  = [];
cfg.method        = 'ortho';
cfg.funparameter  = 'pow';







%cfg.maskparameter = 'pow';
cfg.funcolorlim   = [MinPow MaxPow];

ft_sourceplot( cfg, sourceMRI );

%ft_sourceplot(cfg,sourcemodel);





%%

cfg =[];
cfg.sourcemodel.pos    = sourceFC.pos;
cfg.sourcemodel.inside = sourceFC.inside';
sourcemodel = ft_prepare_sourcemodel(cfg);

cfg            = [];
cfg.downsample = 2;
cfg.parameter  = 'pow';
sourceClassic  = ft_sourceinterpolate(cfg, picFC , sourcemodel);

cfg  = [];
cfg.method        = 'ortho';
cfg.funparameter  = 'pow';
%cfg.maskparameter = 'pow';
cfg.funcolorlim   = [MinPow MaxPow];

ft_sourceplot( cfg, sourceClassic );

%%

cfg =[];
cfg.sourcemodel.pos    = sourceFC.pos;
cfg.sourcemodel.inside = sourceFC.inside';
sourcemodel = ft_prepare_sourcemodel(cfg);

cfg = [];
cfg.funparameter = 'avg.pow';
ft_sourcemovie(cfg,sourcemodel);

%% ADDITIONAL PLOTS
%
figure()
ft_plot_headshape(sourcespace, 'unit', 'cm','facealpha', 0.9)
ft_plot_vol(vol, 'unit', 'cm','facealpha', 0.1, 'edgecolor','r')
ft_plot_sens(elec, 'unit', 'mm', 'label','label', 'orientation',true,...
    'elecsize',7 )
box on
ft_plot_axes([], 'unit', 'cm');
figure()
ft_plot_headshape(sourcespace, 'unit', 'cm')
