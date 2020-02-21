% align_electrodes_script.m
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

%% Interactive alignment
% if the automatic alignment is not perfect, you can further manually align
cfg           = [];
cfg.method    = 'interactive';
cfg.elec      = elec;
cfg.headshape = vol.bnd(1);
elec_aligned_new  = ft_electroderealign(cfg);
save elec_aligned_new elec_aligned_new;

