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
dirName = 'Mouse brain from Lilin';
pathName = [inputDir, filesep, dirName];
prefix = 'Head';
suffix = '.img';
fileName = [prefix, suffix];

fullName = [pathName, filesep, fileName];
mri = ft_read_mri(fullName);

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
outputDirFull = [outputDir, filesep, dirName];
if ~isdir(outputDirFull)
    mkdir(outputDirFull);
end
cfg             = [];
cfg.filename    = [outputDirFull, filesep, prefix];
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri_tal);

cfg.filename    = [outputDirFull, filesep, prefix, '_masked'];
ft_volumewrite(cfg, seg);

disp('done!');

%% Source model: Volumetric processing in Freesurfer (do it on server)
% # set up your environmental variables
% export FREESURFER_HOME=<path to Freesurfer>
% export SUBJECTS_DIR=<Subject directory>
% 
% # set up Freesurfer
% source $FREESURFER_HOME/SetUpFreeSurfer.sh
% 
% # set up a subject-specific directory
% mksubjdirs $SUBJECTS_DIR/Subject01
% 
% # convert the anatomical MRI. All the Freesurfer commands will be called from the "mri" directory.
% cp Subject01masked.mgz $SUBJECTS_DIR/Subject01/mri/Subject01masked.mgz
% cp Subject01.mgz $SUBJECTS_DIR/Subject01/mri/Subject01.mgz
% cd $SUBJECTS_DIR/Subject01/mri/
% mri_convert -c -oc 0 0 0 Subject01masked.mgz orig.mgz
% mri_convert -c -oc 0 0 0 Subject01.mgz orig-nomask.mgz
% 
% # We now have a 'brainmasked' anatomical volume in orig.mgz
% recon-all -talairach -subjid Subject01
% recon-all -nuintensitycor -subjid Subject01
% recon-all -normalization -subjid Subject01
% cp T1.mgz brainmask.mgz
% recon-all -gcareg -subjid Subject01
% recon-all -canorm -subjid Subject01
% recon-all -careg -subjid Subject01
% recon-all -calabel -subjid Subject01
% recon-all -normalization2 -subjid Subject01
% recon-all -segmentation -subjid Subject01
% recon-all -fill -subjid Subject01
% 
% # We now have a file filled.mgz containing the segmentation of the cortical
% # white matter (cerebellum is not included!)

%% Source model: Surface based processing in Freesurfer
% # The surface construction is also done in Subject01/mri directory.
% recon-all -tessellate -subjid Subject01
% recon-all -smooth1 -subjid Subject01
% recon-all -inflate1 -subjid Subject01
% recon-all -qsphere -subjid Subject01
% recon-all -fix -subjid Subject01
% cp brain.mgz brain.finalsurfs.mgz
% recon-all -finalsurfs -subjid Subject01
% recon-all -smooth2 -subjid Subject01
% recon-all -inflate2 -subjid Subject01
% recon-all -sphere -subjid Subject01
% recon-all -surfreg -subjid Subject01
% 
% # We are going to use lh.white and rh.white in Subject01/surf/ directory.

%% Source model: Creation of the mesh using MNE Suite
% # set up environmental variables 
% export MNE_ROOT=<MNE directory>
% cd $MNE_ROOT/bin
% . ./mne_setup_sh
% export SUBJECTS_DIR=<Subject directory>
% export SUBJECT=Subject01
% 
% # create the source space
% mne_setup_source_space --ico -6
% 
% # There are different representations of the source space in
% # <Subject directory>/Subject01/bem/
% # FieldTrip will use the Subject01-oct-6-src.fif file.



