% check_electrodes_vol_script.m
% http://www.fieldtriptoolbox.org/tutorial/headmodel_eeg


clear all;
close all;
clc;

% addpath('../fieldtrip-20130901');
addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults;

load vol_template;
load sourcespace_template;
%load elec_biosemi;
load elec_template;

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
