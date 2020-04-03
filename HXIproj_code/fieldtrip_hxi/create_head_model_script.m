% create_head_model_script.m
% http://www.fieldtriptoolbox.org/tutorial/headmodel_eeg


%%
clear all;
close all;
clc;

addpath(genpath(pwd));
ft_defaults;

%% Preprocessing of the anatomical MRI: read in MRI data
% pathName = '..\data\input\Mouse brain atlas';
% fileName = 'Num1_MinDef_M_Normal_age12_num10Atlas.img';
inputDir = '..\data\input';
outputDir = '..\data\output';
dirName = 'Subject01';
pathName = [inputDir, filesep, dirName];
prefix = 'Subject01';
suffix = '.mri'; %img,mri
fileName = [prefix, suffix];

fullName = [pathName, filesep, fileName];
mri = ft_read_mri(fullName);
disp(mri);

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
save mrirs mrirs;

%% Segmentation.
cfg           = [];
cfg.output    = {'brain','skull','scalp'};
seg  = ft_volumesegment(cfg, mri);

save seg seg
disp(seg)

%% Find the boundaries for brain, skull and scalp.
cfg             = [];
cfg.tissue      = {'brain','skull','scalp'};
cfg.numvertices = [3000 2000 1000];
bnd             = ft_prepare_mesh(cfg,seg);

save bnd bnd
disp(bnd(1))

%% Create head model (or called volume conduction model) with BEM method.
% This code has to be run on linux platform.
cfg        = [];
cfg.method = 'dipoli';
vol        = ft_prepare_headmodel(cfg, bnd);

save vol vol
disp(vol)

%% Visualization
load vol
figure;
ft_plot_mesh(vol.bnd(1),'facecolor','none'); %scalp
figure;
ft_plot_mesh(vol.bnd(2),'facecolor','none'); %skull
figure;
ft_plot_mesh(vol.bnd(3),'facecolor','none'); %brain
 
%% Align the electrodes
% elctrode files are in fieldtrip-20140903/template/electrode
elec = ft_read_sens('standard_1020.elc');

disp(elec)

% load volume conduction model
load vol;                              
figure;

% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;

% electrodes
ft_plot_sens(elec,'style', 'sk');  

% Align scalp and electrodes automatically
disp(mri.hdr.fiducial.mri)
% nas: [87 60 116]
% lpa: [29 145 155]
% rpa: [144 142 158]

% get these positions in the ctf coordinate system using the transformation
% matrix of the mri and the warp_apply function.
nas=mri.hdr.fiducial.mri.nas;
lpa=mri.hdr.fiducial.mri.lpa;
rpa=mri.hdr.fiducial.mri.rpa;
 
transm=mri.transform;
 
nas=ft_warp_apply(transm,nas, 'homogenous');
lpa=ft_warp_apply(transm,lpa, 'homogenous');
rpa=ft_warp_apply(transm,rpa, 'homogenous');


