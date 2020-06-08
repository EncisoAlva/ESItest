%%
clear all;
close all;
clc;

addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults;

%% copy server/Subject01/bem/Subject01-oct-6-src.fif to local/data/input/Subject01

%% Source model: Co-registration of the source space to the sensor-based head coordinate system
% visualize the source space
inputDir = '../data/input';
outputDir = '../data/output';
dirName_mne = 'Subject01';
%dirName_mne = 'Subject01_20150906';
%dirName_mne = 'Subject01_20151013';
pathName_mne = [inputDir, filesep, dirName_mne];
prefix_mne = 'Subject01-oct-6-src';
suffix_mne = '.fif';
fileName_mne = [prefix_mne, suffix_mne];
fullName_mne = [pathName_mne, filesep, fileName_mne];

sourcespace = ft_read_headshape(fullName_mne, 'format', 'mne_source');
save sourcespace sourcespace;

figure;ft_plot_mesh(sourcespace);
view(0,0); % lateral

figure;ft_plot_mesh(sourcespace);
view(0,90); % top





%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following are to be removed when vol is successfully created!






%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # convert .mgz file to .mgh file using freesurfer (do it on server)
% export FREESURFER_HOME="/home/hongguang/freesurfer"
% source $FREESURFER_HOME/SetUpFreeSurfer.sh
% cd /home/hongguang/data/Subject01/mri
% mri_convert orig-nomask.mgz orig-nomask.mgh

% Now you can move .mgh file to PC.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
% load in the conformed anatomical image
prefix_orig = 'orig-nomask';
suffix_orig = '.mgh';
fileName_orig = [prefix_orig, suffix_orig];
fullName_orig = [pathName_mne, filesep, fileName_orig];

mri_nom = ft_read_mri(fullName_orig);

% coregister the anatomical MRI to the sensor's coordinate system
cfg = [];
cfg.method = 'interactive';
mri_nom_ctf = ft_volumerealign(cfg, mri_nom);

%%
% get sourcespace and the transformation matrix T
mri_nom_ctf = ft_convert_units(mri_nom_ctf, 'mm');
T   = mri_nom_ctf.transform*inv(mri_nom_ctf.transformorig);
bnd  = ft_read_headshape(fullName_mne, 'format', 'mne_source');
sourcespace = ft_convert_units(bnd, 'mm');
sourcespace = ft_transform_geometry(T, sourcespace);
save sourcespace sourcespace;
save T T;

%% Volume conduction model (run in limux matlab)
% get a volume conduction model that is aligned with the source space
cfg           = [];
%cfg.coordsys  = 'spm'; % outdated!!!
mri_nom.coordsys  = 'spm';
cfg.output    = {'skull' 'scalp' 'brain'};%{'brain'};
seg           = ft_volumesegment(cfg, mri_nom);
seg           = ft_convert_units(seg,'mm');

cfg           = [];
cfg.method    = 'singleshell';%'dipoli';%'singleshell';
vol           = ft_prepare_headmodel(cfg,seg);
vol.bnd(1)       = ft_transform_geometry(T, vol.bnd(1));
vol.bnd(2)       = ft_transform_geometry(T, vol.bnd(2));
vol.bnd(3)       = ft_transform_geometry(T, vol.bnd(3));
save vol vol;

figure;hold on;
ft_plot_vol(vol, 'facecolor', 'none');alpha 0.5;
%ft_plot_mesh(sourcespace, 'edgecolor', 'none'); camlight;%sourcespace
view(0,180);

%% test
% check if the resulting sourcespace and the volume conductor are aligned
load sourcespace_template;
load vol_template;

vol1=vol;vol1.bnd=vol.bnd(1);
vol2=vol;vol2.bnd=vol.bnd(2);
vol3=vol;vol3.bnd=vol.bnd(3);

figure;hold on;
ft_plot_mesh(sourcespace, 'edgecolor', 'none'); camlight;%sourcespace
view(0,0);

figure;hold on;
ft_plot_vol(vol1, 'facecolor', 'none');alpha 0.5;
ft_plot_mesh(sourcespace, 'edgecolor', 'none'); camlight;%sourcespace
view(0,180);

figure;hold on;
ft_plot_vol(vol2, 'facecolor', 'none');alpha 0.5;
ft_plot_mesh(sourcespace, 'edgecolor', 'none'); camlight;%sourcespace
view(0,180);

figure;hold on;
ft_plot_vol(vol3, 'facecolor', 'none');alpha 0.5;
ft_plot_mesh(sourcespace, 'edgecolor', 'none'); camlight;%sourcespace
view(0,180);

ft_plot_mesh(vol.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3, 'edgecolor', [1 1 1], 'edgealpha', 0.05);
hold on;
ft_plot_mesh(vol.bnd(2),'edgecolor','none','facealpha',0.4);
hold on;
ft_plot_mesh(vol.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);

% The open problem is that we still cannot generate a head model s.t. the
% sourcespace can fit in. Temporarily, I have to use a head model from FT
% template (see tutortial on eeg head model in FieldTrip).
