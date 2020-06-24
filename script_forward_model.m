% Generate forward model (leadfield) given an MRI and electrode locations
% with labels. Manual input is required to identify fiducials and align
% electrodes with head.
% Template MRI is considered.
%
% Curated by EA for a project on EEG reconstruction. Based on code by HXI 
% for a similar, previous project.
%
% For reference, check the following tutorials:
% http://www.fieldtriptoolbox.org/tutorial/headmodel_eeg
% http://www.fieldtriptoolbox.org/tutorial/sourcemodel/

%% CHANGELOG
% 2020-06-08
%    Curated by EA for a project on EEG reconstruction. Based on code by
%    HXI for a similar, previous project.
% 2020-06-20
%    Change on directory organization in order to better report and share
%    with pairs.

%% CONFIG OUTSIDE MATLAB
% external function 'dipoli' only runs on linux with admin permissions; to
% grant such permissions do the following:
%   1. locate  ../fieldtrip-'version'/external/dipoli' ] )
%   2. open directory in a terminal
%   3. run: chmod +x dipoli.glnx86
%
% http://www.fieldtriptoolbox.org/faq/where_can_i_find_the_dipoli_command-line_executable/

%% DIRECTORY STRUCTURE
%  MATLAB-Drive
%  |> fieldtrip-**version**
%  |  |> template
%  |> ESIproj_data
%  |  |> waterpain
%  |  |  |  easycap-M1_hxi64_haley.txt
%  |  |  |  standard_mri.mat
%  |> ESIproj_code
%  |   |  -- this file --
%  |   |> legacy
%  |   |  |  read_elecrodes_position.m
%  |   |> EAtemplates
%  |   |  | -- results --

%% WORKING DIR
%
% input/outup dir
innDIR = [ '../ESIproj_data/waterpain' ];
outDIR = [ './EAtemplates' ];

% code written by others before
addpath([ './legacy' ])

% FieldTrip dir + init
FTver = '20200227'; % update if fieldtrip is changed
addpath([ '../../fieldtrip-',FTver ])
ft_defaults    % initialization

%% MRI PROCESSING
%
% read MRI
load standard_mri

% realign to CTF: manually select nasion (N) and left/righ auricular point 
% (LPA/RPA)
% follow instructions on terminal
if ~isfield(mri,'coordsys') || ~strcmpi(mri.coordsys, 'ctf')
    % manually get the correct orientation
    mri = ft_determine_coordsys(mri, 'interactive', 'yes');
    
    % manually identify fiducials
    cfg = [];
    cfg.method = 'interactive';
    mri = ft_volumerealign(cfg, mri);
end

% reslicing
cfg = [];
cfg.resolution = 1;
cfg.dim        = [256 256 256];
mri_resliced = ft_volumereslice(cfg, mri);

% segmentation
cfg = [];
%cfg.output    = {'gray','white','csf','skull','scalp'};
cfg.output    = {'brain','skull','scalp'};
segmentedmri  = ft_volumesegment(cfg, mri_resliced);

save segmentedmri segmentedmri;
save mri_resliced mri_resliced;

%% FORWARD MODEL CONDUCTOR
%
% surfaces are created at the boarders of the different tissue-types
cfg = [];
cfg.tissue      = {'brain','skull','scalp'};
cfg.numvertices = [3000 2000 1000];
bnd = ft_prepare_mesh(cfg,segmentedmri);

save bnd bnd;

% BEM model, volume conduction model
cfg = [];
cfg.method = 'dipoli';
vol        = ft_prepare_headmodel(cfg, bnd);

save vol vol;

% visual inspection
if false
figure()
ft_plot_mesh(vol.bnd(1),'facecolor','none'); %scalp
view(0,0); % lateral

figure()
ft_plot_mesh(vol.bnd(2),'facecolor','none'); %skull
view(0,0); % lateral

figure()
ft_plot_mesh(vol.bnd(3),'facecolor','none'); %brain
view(0,0); % lateral

% combined view
figure()
ft_plot_mesh(vol.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3,...
    'edgecolor', [1 1 1], 'edgealpha', 0.05);
hold on;
ft_plot_mesh(vol.bnd(2),'edgecolor','none','facealpha',0.4);
hold on;
ft_plot_mesh(vol.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);
view(0,0); % lateral
end

%% ELECTRODE POSITION
%
% read coordinates of electrodes
% elec = ft_read_sens('standard_1020.elc')
elec = read_elecrodes_position('easycap-M1_hxi64_haley.txt');

% visual inspection
if false
figure()
% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,...
    'facecolor',[0.6 0.6 0.8]); 
hold on;
% electrodes
ft_plot_sens(elec,'label','label');    
view([0 90]);
end

% interactive alignment
cfg           = [];
cfg.method    = 'interactive';
cfg.elec      = elec;
cfg.headshape = vol.bnd(1);
elec_aligned_new  = ft_electroderealign(cfg);

% verification of coordinates
cfg.grad      = elec_aligned_new;
elec_aligned_new  = ft_electroderealign(cfg);

save elec_aligned_new elec_aligned_new;

% visual inspection, again
if false
figure()
% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,...
    'facecolor',[0.6 0.6 0.8]); 
hold on;
% electrodes
ft_plot_sens(elec_aligned_new,'label','label');    
view([0 90]);
end

%% FORWARD MODEL, AKA LEADFIELD
%
% forward model per se
cfg = [];
cfg.elec        = elec_aligned_new;   % sensor positions as electrodes
%cfg.grad        = elec_aligned_new;   % sensor positions as gradiometers
cfg.channel     = {'all'};            % the used channels
cfg.headmodel   = vol;                % volume conduction model
cfg.resolution  = 5;
cfg.unit        = 'mm';

leadfield = ft_prepare_leadfield(cfg);

save leadfield leadfield;

