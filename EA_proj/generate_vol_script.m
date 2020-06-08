% Generate brain-skull-scalp geometry (vol) and forward model (leadfield)
% for source reconstruction. Template MRI is considered.
%
% http://www.fieldtriptoolbox.org/tutorial/headmodel_eeg
% 

%% CHANGELOG
% 2020-06-08
%    Added to EA proj.
%    Fused generate_vol_script.

%% CONFIG OUTSIDE MATLAB
% external function 'dipoli' only runs on linux with admin permissions; to
% grant such permissions do the following:
%   1. locate  ../fieldtrip-'version'/external/dipoli' ] )
%   2. open directory in a terminal
%   3. run: chmod +x dipoli.glnx86
%
% http://www.fieldtriptoolbox.org/faq/where_can_i_find_the_dipoli_command-line_executable/

%% WORKING DIR
%
% template MRI from FieldTrip
addpath([ '../../FT_template/headmodel' ])

% FieldTrip directory+init
FTversion = '20200227'; % update if fieldtrip is changed
addpath([ '../../fieldtrip-',FTversion ])
ft_defaults    % initialization

%% MRI PROCESSING
%
% read MRI
load standard_mri

% realign to CTF: manually select nasion (N) and left/righ auricular point 
% (LPA/RPA)
% follow instructions on terminal
if ~isfield(mri,'coordsys') || ~strcmpi(mri.coordsys, 'ctf')
    mri = ft_determine_coordsys(mri, 'interactive', 'yes');
    
    cfg=[];
    cfg.method = 'interactive';
    mri = ft_volumerealign(cfg, mri);
end

% reslicing
cfg            = [];
cfg.resolution = 1;
cfg.dim        = [256 256 256];
mrirs          = ft_volumereslice(cfg, mri);

% segmentation
cfg           = [];
%cfg.output    = {'gray','white','csf','skull','scalp'};
cfg.output    = {'brain','skull','scalp'};
segmentedmri  = ft_volumesegment(cfg, mrirs);

save segmentedmri segmentedmri;

%% FORWARD MODEL CONDUCTOR
%
% surfaces are created at the boarders of the different tissue-types
cfg=[];
cfg.tissue={'brain','skull','scalp'};
cfg.numvertices = [3000 2000 1000];
bnd=ft_prepare_mesh(cfg,segmentedmri);

save bnd bnd;

% BEM model, volume conduction model
cfg        = [];
cfg.method ='dipoli';
vol        = ft_prepare_headmodel(cfg, bnd);
save vol vol;

%% VISUAL INSPECTION
%
figure;
ft_plot_mesh(vol.bnd(1),'facecolor','none'); %scalp
view(0,0); % lateral

figure;
ft_plot_mesh(vol.bnd(2),'facecolor','none'); %skull
view(0,0); % lateral

figure;
ft_plot_mesh(vol.bnd(3),'facecolor','none'); %brain
view(0,0); % lateral

% combined view
figure;
ft_plot_mesh(vol.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3, 'edgecolor', [1 1 1], 'edgealpha', 0.05);
hold on;
ft_plot_mesh(vol.bnd(2),'edgecolor','none','facealpha',0.4);
hold on;
ft_plot_mesh(vol.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);
view(0,0); % lateral
