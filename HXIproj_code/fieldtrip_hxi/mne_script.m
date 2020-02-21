%%
clear all;
close all;
clc;

addpath(genpath(pwd));
ft_defaults;

%% Preprocessing of the anatomical MRI: read in MRI data
pathName = '..\data\input\Subject01';
fileName = 'Subject01.mri';
fullName = [pathName, filesep, fileName];
mri = ft_read_mri(fullName);

%% Preprocessing of the anatomical MRI: realign to CTF
% Please check the structure content of mri, if you didn't find 'ctf', then
% run this section.

if ~strcmpi(mri.coordsys, 'ctf')
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

%% Preprocessing of the anatomical MRI: segmentation

% segmentation of the mri
load mrirs;
cfg           = [];
cfg.coordsys  = 'ctf';
cfg.output    = {'skullstrip' 'brain'};
seg           = ft_volumesegment(cfg, mrirs);
save seg seg;

%% Preprocessing of the anatomical MRI: realign to Talairach

load mrirs;
cfg        = [];
cfg.method = 'interactive';
mri_tal    = ft_volumerealign(cfg, mrirs);
save mri_tal mri_tal                  %we will need this structure at 
                                      %later stages (save to disk)

%% Preprocessing of the anatomical MRI: save to disk

load mri_tal;
load seg;

% ensure that the skull-stripped anatomy is expressed in the same coordinate system as the anatomy
seg.transform = mri_tal.transform;

% save both the original anatomy, and the masked anatomy in a freesurfer compatible format
cfg             = [];
cfg.filename    = 'Subject01';
cfg.filetype = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri_tal);

cfg.filename    = 'Subject01masked';
ft_volumewrite(cfg, seg);

disp('done!');












