% Electric Source Imaging (ESI) from EEG using FieldTrip. Attention is
% focused on a couple Regions of Interest (ROI).
% Based on code by HXI for a similar, previous project.
%
% Head model for ESI is based on a template MRI (standard_mri).
% https://github.com/fieldtrip/fieldtrip/tree/master/template/headmodel
% Processing for the ESI head model is done in generate_forward_model.

%% CHANGELOG
% 2020-06-11
%    Updated previous script using leadfield computed by EA.
% 2020-06-20
%    Change on directory organization in order to better report and share
%    with pairs.

%% DIRECTORY STRUCTURE
%  MATLAB-Drive
%  |> HXIproj_data/input/Peng
%  |   | waterpain1.eeg
%  |   | waterpain1.vhdr
%  |   | waterpain1.vmrk
%  |> fieldtrip-***version***
%  |> ESItest
%  |   |> EAproj_code
%  |   |  | -- this file --
%  |   |> EA_templates
%  |   |  | elec_algned_new.mat
%  |   |  | segmentedmri.mat

%% WORKING DIR + PARAMETERS + INIT
%
% EEG data dir
dataDIR   = '../../HXIproj_data/';
inDIR     = [ dataDIR, 'input/Peng' ];
filePATH  = [ inDIR, '/waterpain1.vhdr' ];

% anatomical data dir
addpath([ '../EA_templates' ]);

% brain atlas provided in FieldTrip
addpath([ '../../FT_template/atlas/brainnetome' ])

% FieldTrip dir + init
FTversion = '20200227'; % update if fieldtrip is changed
addpath([ '../../fieldtrip-',FTversion ])
ft_defaults    % initialization

% specific segments: [-prestim,poststim] with 0 at stimulus
% unit is second
prestim  = 4;
poststim = 6;

%LAMBDA = 3;

%% DATA LOAD + PRE-PROCESSING
%
% precomputed anatomical data
load elec_aligned_new;
load leadfield;
load mri_resliced;
load segmentedmri;
load vol;

% waterpain data
cfg = [];
cfg.dataset            = filePATH; % path+name of dataset  
cfg.trialfun           = 'hx_trialfun_general'; % trial detecion function
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.pre       = prestim;
cfg.trialdef.post      = poststim;
cfg = ft_definetrial(cfg);
cfg.channel = {'all'}; % read all MEG channels except MLP31 and MLO12

% one trial at the time; this var will be used to process on batch
CHOSEN_TRIAL = 3;
cfg.trl( setdiff(1:13,CHOSEN_TRIAL) ,:) = [];

% preprocessing
dataFC_LP = ft_preprocessing(cfg);

% visual inspection of data
if false
cfg = [];
cfg.viewmode   = 'butterfly';
cfg.continuous = 'no';
cfg.channel    = elec_aligned_new.label;

cfg.plotlabels ='yes'; 
ft_databrowser( cfg,dataFC_LP )
end

%  noise-covariance estimation
cfg = [];
cfg.covariance = 'yes';
cfg.channel    = {'all'};
cfg.grad       = elec_aligned_new;

tlckFC  = ft_timelockanalysis( cfg,dataFC_LP );

%% INVERSE SOLUTION
%
cfg = [];
cfg.method      = 'mne';
cfg.channel     = {'all'};
cfg.elec        = elec_aligned_new;
cfg.sourcemodel = leadfield;
cfg.headmodel   = vol;
cfg.normalize   = 'yes';
cfg.mne.prewhiten      = 'yes';
cfg.mne.lambda         = LAMBDA; %3;
%cfg.mne.scalesourcecov = 'yes'; % preferred if mixed channels
% cfg.keepleadfield      = 'yes';


sourceFC  = ft_sourceanalysis(cfg, tlckFC);

%% DATA POST-PROCESSING
%
% backup var
picFC  = sourceFC;

% moving average, overlapping windows
% downsampled at 1 Hz for visualization
WINDOW_LEN = 1; % size of overlapping windows
[n_sources, n_timepoints] = size(picFC.avg.pow);
n_windows  = floor( n_timepoints/dataFC_LP.fsample ) - WINDOW_LEN + 1;
CARRIER    = zeros(n_sources, n_windows);
for snap = 0:(n_windows-1)
    TimeWin = (1+snap*1000):(snap+WINDOW_LEN)*1000;
    CARRIER(:,snap+1) = nanmean( sourceFC.avg.pow(:,TimeWin), 2 );
end

% aestethic normalization: fake removal of outliers
% colorspace is reduced within 1st/3rd quartile +/- 1.5 InterQuartile Range
% this is done to invisibilize the visual effect of outliers
IQ   = iqr(CARRIER(:));
MinZ = quantile(CARRIER(:),0.25) - 1.5*IQ;
MaxZ = quantile(CARRIER(:),0.75) + 1.5*IQ;

MinPow = max( min(CARRIER(:)), MinZ ); % these are the new color bounds
MaxPow = min( max(CARRIER(:)), MaxZ );

%MinPow = ( min(CARRIER(:)) ); % these are the new color bounds
%MaxPow = ( max(CARRIER(:)) );

%% FOR REPORT: SNAPSHOTS OF ACTIVITY
% cfg  = [];
% cfg.method       = 'surface';
% cfg.funparameter = 'pow';
% cfg.funcolorlim  = [MinPow MaxPow];
% 
% % for snap = 0:(n_windows-1)
%     snap = 0;
%     picFC.avg.pow = CARRIER(:,snap+1);
%     ft_sourceplot( cfg, picFC );
    
%     set(gcf, 'PaperUnits', 'inches');
%     x_width = 2*4/3;
%     y_width = 2*4/3;
%     set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
%     saveas(gcf,['brn',num2str(CHOSEN_TRIAL,'%02d'),'_',...
%         num2str(snap,'%02d'),'.png'])
%     close all
% end

%% TEMPLATE MRI FOR VISUALIZATION
%
% % visual inspection of mri
% ft_sourceplot([],mri_resliced)

% backup var
picFC  = sourceFC;

%for Snap = 0:8
snap = 0;
picFC.avg.pow = CARRIER(:,snap+1);

picFC.avg.pow = sourceFC.avg.pow(:,5000);

% interpolation to mri's voxels
cfg            = [];
cfg.downsample = 2;
cfg.parameter  = 'pow';
sourceMRI  = ft_sourceinterpolate(cfg, picFC , mri_resliced);

% plot within mri
cfg  = [];
cfg.method        = 'ortho';
cfg.funparameter  = 'pow';
cfg.maskparameter = 'pow';
cfg.funcolorlim   = [MinPow MaxPow];
ft_sourceplot( cfg, sourceMRI );

%      set(gcf, 'PaperUnits', 'inches');
%      x_width = 2*4;
%      y_width = 2*4;
%      set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
%      saveas(gcf,['lam',num2str(t,'%02d'),'.png'])
%      close all

%% ADDITIONAL PLOTS
%
if false
figure()
%ft_plot_headshape(sourcespace, 'unit', 'cm','facealpha', 0.9)
ft_plot_vol(vol,'facealpha', 0.1, 'edgecolor','r')
ft_plot_sens(elec_aligned_new, 'unit', 'mm', 'label','label',...
    'orientation',true, 'elecsize',7 )
box on
end

%% ATLAS
%
% Brainnetome atlas is is recent (2016) and specific (123 subregions)
brainnetome = ft_read_atlas('BNA_MPM_thr25_1.25mm.nii');

% alignment of atlas
%ft_determine_coordsys(brainnetome, 'interactive', 'yes');
brainnetome = ft_convert_coordsys(brainnetome,'ctf');

% Regions of Interest (ROI) are selected
cfg = [];
cfg.atlas      = brainnetome;
cfg.roi        = brainnetome.tissuelabel;  % here you can also specify a single label, i.e. single ROI
%cfg.inputcoord = 'mni';
mask           = ft_volumelookup(cfg, segmentedmri);

cfg= [];
cfg.atlas = brainnetome;
cfg.method        = 'ortho';
cfg.funparameter  = 'pow';
%cfg.maskparameter = 'pow';
cfg.roi        = brainnetome.tissuelabel;
cfg.funcolorlim   = [MinPow MaxPow];
ft_sourceplot( cfg, segmentedmri );
