%%
clear all;
close all;
clc;

addpath(genpath(pwd));
ft_defaults;

%% Source model: Co-registration of the source space to the sensor-based head coordinate system
% visualize the source space
inputDir = '..\data\input';
outputDir = '..\data\output';
dirName_mne = 'MouseBrainAfterMNE';
pathName_mne = [inputDir, filesep, dirName_mne];
prefix_mne = 'Subject01-oct-6-src';
suffix_mne = '.fif';
fileName_mne = [prefix_mne, suffix_mne];
fullName_mne = [pathName_mne, filesep, fileName_mne];

bnd = ft_read_headshape(fullName_mne, 'format', 'mne_source');
figure;ft_plot_mesh(bnd);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% # convert .mgz file to .mgh file using freesurfer (do it on server)
% export FREESURFER_HOME="/home/hongguang/Desktop/freesurfer"
% source $FREESURFER_HOME/SetUpFreeSurfer.sh
% cd /home/hongguang/Desktop/MoueseBrainFromLilin/Subject01/mri
% mri_convert orig-nomask.mgz orig-nomask.mgh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% get sourcespace and the transformation matrix T
mri_nom_ctf = ft_convert_units(mri_nom_ctf, 'cm');
T   = mri_nom_ctf.transform*inv(mri_nom_ctf.transformorig);
bnd  = ft_read_headshape(fullName_mne, 'format', 'mne_source');
sourcespace = ft_convert_units(bnd, 'cm');
sourcespace = ft_transform_geometry(T, sourcespace);
save sourcespace sourcespace;
save T T;

%% Volume conduction model
% get a volume conduction model that is aligned with the source space
cfg           = [];
%cfg.coordsys  = 'spm'; % outdated!!!
mri_nom.coordsys  = 'spm';
cfg.output    = {'brain'};
seg           = ft_volumesegment(cfg, mri_nom);
seg           = ft_convert_units(seg,'cm');

cfg           = [];
cfg.method    = 'singleshell';
vol           = ft_prepare_headmodel(cfg,seg);
vol.bnd       = ft_transform_geometry(T, vol.bnd);
save vol vol;

% check if the resulting sourcespace and the volume conductor are aligned
figure;hold on;
ft_plot_vol(vol, 'facecolor', 'none');alpha 0.5;
ft_plot_mesh(sourcespace, 'edgecolor', 'none'); camlight


















