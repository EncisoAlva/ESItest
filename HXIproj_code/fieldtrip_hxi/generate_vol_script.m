% generate_vol_script.m
% http://www.fieldtriptoolbox.org/tutorial/headmodel_eeg

clear all;
close all;
clc;

addpath('../fieldtrip-20130901');
ft_defaults;

%% make sure on server change one file to executable.
% cd EEG_DATA/fieldtrip-20130901/external/dipoli
% chmod +x dipoli.glnx86

%% Preprocessing of the anatomical MRI: read in MRI data
% pathName = '..\data\input\Mouse brain atlas';
% fileName = 'Num1_MinDef_M_Normal_age12_num10Atlas.img';
inputDir = '../data/input';
outputDir = '../data/output';
dirName = 'Subject01';
pathName = [inputDir, filesep, dirName];
prefix = 'Subject01';
suffix = '.mri'; %img,mri
fileName = [prefix, suffix];

fullName = [pathName, filesep, fileName];

mri = ft_read_mri(fullName) % check mri.coordsys in command window. 
% If it is not ctf, we need realignment.
% If it is ctf, never do realignemtn.

%% Preprocessing of the anatomical MRI: realign to CTF
% Please check the structure content of mri, if you didn't find 'ctf', then
% run this section.

if ~isfield(mri,'coordsys') || ~strcmpi(mri.coordsys, 'ctf')
    mri = ft_determine_coordsys(mri, 'interactive', 'yes');
    
    cfg=[];
    cfg.method = 'interactive';
    mri = ft_volumerealign(cfg, mri);
end

%% Preprocessing of the anatomical MRI: reslicing
cfg            = [];
cfg.resolution = 1;
cfg.dim        = [256 256 256];
mrirs          = ft_volumereslice(cfg, mri);

%% Preprocessing of the anatomical MRI: segmentation
cfg           = [];
cfg.output    = {'brain','skull','scalp'};
segmentedmri  = ft_volumesegment(cfg, mrirs)

save segmentedmri segmentedmri;

%% Mesh
% Surfaces are created at the boarders of the different tissue-types. 
cfg=[];
cfg.tissue={'brain','skull','scalp'};
cfg.numvertices = [3000 2000 1000];
bnd=ft_prepare_mesh(cfg,segmentedmri)

save bnd bnd;

%% Head model (BEM model, volume conduction model)
cfg        = [];
cfg.method ='dipoli';
vol        = ft_prepare_headmodel(cfg, bnd)

save vol vol;

%% Visualization
figure;
ft_plot_mesh(vol.bnd(1),'facecolor','none'); %scalp
view(0,0); % lateral
figure;
ft_plot_mesh(vol.bnd(1),'facecolor','none'); %scalp
view(0,90); % top

figure;
ft_plot_mesh(vol.bnd(2),'facecolor','none'); %skull
view(0,0); % lateral
figure;
ft_plot_mesh(vol.bnd(2),'facecolor','none'); %skull
view(0,90); % top

figure;
ft_plot_mesh(vol.bnd(3),'facecolor','none'); %brain
view(0,0); % lateral
figure;
ft_plot_mesh(vol.bnd(3),'facecolor','none'); %brain
view(0,90); % top

% combined view
figure;
ft_plot_mesh(vol.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3, 'edgecolor', [1 1 1], 'edgealpha', 0.05);
hold on;
ft_plot_mesh(vol.bnd(2),'edgecolor','none','facealpha',0.4);
hold on;
ft_plot_mesh(vol.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);
view(0,0); % lateral

figure;
ft_plot_mesh(vol.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3, 'edgecolor', [1 1 1], 'edgealpha', 0.05);
hold on;
ft_plot_mesh(vol.bnd(2),'edgecolor','none','facealpha',0.4);
hold on;
ft_plot_mesh(vol.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);
view(0,90); % top


