# Rename .mgh to .mgz

# copy Subject01.mgz and Subject01_masked.mgz to server (/home/hongguang/)
# these two files should be in the same folder as this batch file.

# set up your environmental variables
export FREESURFER_HOME="/home/hongguang/freesurfer"
export SUBJECTS_DIR="/home/hongguang/data"

# set up Freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

# set up a subject-specific directory
mksubjdirs $SUBJECTS_DIR/Subject01

# convert the anatomical MRI. All the Freesurfer commands will be called from the "mri" directory.
cp Subject01masked.mgz $SUBJECTS_DIR/Subject01/mri/Subject01masked.mgz
cp Subject01.mgz $SUBJECTS_DIR/Subject01/mri/Subject01.mgz
cd $SUBJECTS_DIR/Subject01/mri/
mri_convert -c -oc 0 0 0 Subject01masked.mgz orig.mgz
mri_convert -c -oc 0 0 0 Subject01.mgz orig-nomask.mgz

# We now have a 'brainmasked' anatomical volume in orig.mgz
recon-all -talairach -subjid Subject01
recon-all -nuintensitycor -subjid Subject01
recon-all -normalization -subjid Subject01
cp T1.mgz brainmask.mgz
recon-all -gcareg -subjid Subject01
recon-all -canorm -subjid Subject01
recon-all -careg -subjid Subject01
recon-all -calabel -subjid Subject01
recon-all -normalization2 -subjid Subject01
recon-all -segmentation -subjid Subject01
recon-all -fill -subjid Subject01

# We now have a file filled.mgz containing the segmentation of the cortical white matter (cerebellum is not included!)

# Source model: Surface based processing in Freesurfer
# The surface construction is also done in Subject01/mri directory.
recon-all -tessellate -subjid Subject01
recon-all -smooth1 -subjid Subject01
recon-all -inflate1 -subjid Subject01
recon-all -qsphere -subjid Subject01
recon-all -fix -subjid Subject01
cp brain.mgz brain.finalsurfs.mgz
recon-all -finalsurfs -subjid Subject01
recon-all -smooth2 -subjid Subject01
recon-all -inflate2 -subjid Subject01
recon-all -sphere -subjid Subject01
recon-all -surfreg -subjid Subject01

# We are going to use lh.white and rh.white in Subject01/surf/ directory.

# Source model: Creation of the mesh using MNE Suite
# set up environmental variables 
export MNE_ROOT="/home/hongguang/MNE-2.7.0-3106-Linux-x86_64"
export MATLAB_ROOT="/home/hongguang/MNE-2.7.0-3106-Linux-x86_64/share/matlab"
cd $MNE_ROOT/bin
. ./mne_setup_sh
export SUBJECTS_DIR="/home/hongguang/data"
export SUBJECT=Subject01

# create the source space
mne_setup_source_space --ico -6
cd ~

# There are different representations of the source space in
# <Subject directory>/Subject01/bem/
# FieldTrip will use the Subject01-oct-6-src.fif file.
