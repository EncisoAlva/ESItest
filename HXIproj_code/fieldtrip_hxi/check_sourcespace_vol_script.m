%check_sourcespace_vol_script.m


clear all;
close all;
clc;

addpath('../fieldtrip-20130901');
ft_defaults;

load vol_template;
load sourcespace_template;

%% check if sourcespace is aligned with vol
% vol
figure;
ft_plot_mesh(vol.bnd(3),'facecolor','none');
view(0,0); % lateral

% sourcespace
figure;hold on;
ft_plot_mesh(sourcespace,'edgecolor','none');
camlight;
view(0,0); % lateral

% sourcespace and vol
% you cannot see the inner part, but if you delete the outer part, you can
% see the brain.
vol3=vol;
vol3.bnd=vol.bnd(3);
figure;hold on;
ft_plot_mesh(sourcespace, 'edgecolor', 'none'); camlight;
ft_plot_vol(vol3, 'facecolor', 'none');alpha 0.5;
view(0,0); % lateral

% brain, skull and scalp
figure;
ft_plot_mesh(vol.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3, 'edgecolor', [1 1 1], 'edgealpha', 0.05);
hold on;
ft_plot_mesh(vol.bnd(2),'edgecolor','none','facealpha',0.4);
hold on;
ft_plot_mesh(vol.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);
view(0,0); % lateral
