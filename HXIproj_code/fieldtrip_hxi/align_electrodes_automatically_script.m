% align_electrodes_automatically_script.m
% http://www.fieldtriptoolbox.org/tutorial/headmodel_eeg


clear all;
close all;
clc;

addpath('../fieldtrip-20130901');
ft_defaults;

load vol_template;
load sourcespace_template;

%% read in 3d-coordinates of electrodes
%elec = ft_read_sens('standard_1020.elc')
elec = read_elecrodes_position('easycap-M1_hxi64_haley.txt')

%% show electrodes on the head                     
figure;

% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;

% electrodes
%ft_plot_sens(elec_aligned,'style', 'sk');
ft_plot_sens(elec,'label','label');    
%view([90 -90]);
view([0 90]);

figure;

% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;

% electrodes
%ft_plot_sens(elec_aligned,'style', 'sk');
ft_plot_sens(elec,'label','label');    
%view([90 -90]);
view([0 0]);

%% get the positions of fiducials in the original mri data
mri = ft_read_mri('../data/input/Subject01/Subject01.mri');
disp(mri.hdr.fiducial.mri);

%% calculate the positions of fiducials in ctf coordinate system
nas=mri.hdr.fiducial.mri.nas;
lpa=mri.hdr.fiducial.mri.lpa;
rpa=mri.hdr.fiducial.mri.rpa;
 
transm=mri.transform;

nas=warp_apply(transm,nas, 'homogenous');
lpa=warp_apply(transm,lpa, 'homogenous');
rpa=warp_apply(transm,rpa, 'homogenous');

%% align electrodes with the head by matching their fiducials' positions
% create a structure similar to a template set of electrodes
fid.chanpos       = [nas; lpa; rpa];       % ctf-coordinates of fiducials
fid.label         = {'Nz','LPA','RPA'};    % same labels as in elec 
fid.unit          = 'mm';                  % same units as mri
 
% I got fiducial positions from standard_1020.lec file, and try to attach
% these 3 rows to elec. If use the original data the left and right are
% switched. So, I switched LPA value and RPA value, and it seems to be
% correct.
fid1020 = [0.0083 86.8110 -39.9830;
            -86.0761 -19.9897 -47.9860;%original RPA
            85.7939 -20.0093 -48.0310];%original LPA
elec.label=[elec.label;{'Nz'};{'LPA'};{'RPA'}];
newpos = [elec.chanpos;fid1020];
elec.chanpos=newpos;
elec.elecpos=newpos;
elec.pnt=newpos;

% alignment
cfg               = [];
cfg.method        = 'fiducial';            
cfg.template      = fid;                   % see above
cfg.elec          = elec;
cfg.fiducial      = {'Nz', 'LPA', 'RPA'};  % labels of fiducials in fid and in elec
elec_aligned      = ft_electroderealign(cfg);

%%
% remove the last 3 labels and their coordinates
newlabel = elec_aligned.label(1:end-3);
newpos = elec_aligned.chanpos(1:end-3,:);

elec = elec_aligned;
elec.label=newlabel;
elec.chanpos=newpos;
elec.elecpos=newpos;
elec.pnt=newpos;

save elec elec;

%% show electrodes on the head                     
figure;

% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;

% electrodes
%ft_plot_sens(elec_aligned,'style', 'sk');
ft_plot_sens(elec_aligned,'label','label');    
%view([90 -90]);
view([0 90]);

figure;

% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;

% electrodes
%ft_plot_sens(elec_aligned,'style', 'sk');
ft_plot_sens(elec_aligned,'label','label');    
%view([90 -90]);
view([0 0]);

figure;

% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;

% electrodes
%ft_plot_sens(elec_aligned,'style', 'sk');
ft_plot_sens(elec,'label','label');    
%view([90 -90]);
view([0 90]);

figure;

% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]); 
hold on;

% electrodes
%ft_plot_sens(elec_aligned,'style', 'sk');
ft_plot_sens(elec,'label','label');    
%view([90 -90]);
view([0 0]);
