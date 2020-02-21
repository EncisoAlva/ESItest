% plot_reconstructed_data_script.m
%
% Hongguang Xi, 11/10/2015.

clc;
clear all;
close all;

%%
%addpath('../fieldtrip-20130901');
addpath('../fieldtrip-20150911');
ft_defaults

load recon_data_rc; % default name is merged_data
load sourcespace_template; % default name is sourcespace

%%
pattern_final = mean(merged_data,2);

%% plot
figure;
ft_plot_mesh(sourcespace, 'vertexcolor', pattern_final);
view(0,90);%top view

figure;
ft_plot_mesh(sourcespace, 'vertexcolor', pattern_final);
view(0,-90);%bottom view
