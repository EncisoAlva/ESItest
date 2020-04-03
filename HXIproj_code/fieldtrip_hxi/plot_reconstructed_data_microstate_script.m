% plot_reconstructed_data_microstate_script.m
%
% Hongguang Xi, 11/10/2015.

clc;
clear all;
close all;

%%
%addpath('../fieldtrip-20130901');
addpath('../fieldtrip-20150911');
ft_defaults

load sourcespace_template; % default name is sourcespace
dataNames = {'recon_data_rw','recon_data_rc','recon_data_lw','recon_data_lc'};
numStates = 3; 

h_top = figure;
hold on;
h_bottom = figure;
hold on;

%% plot a 4x10 figure
counter = 1;
for j = 1 : length(dataNames); % default name is merged_data
    load(dataNames{j});
    merged_data = abs(merged_data);
    time_window = size(merged_data,2) / numStates;
    for i = 1 : time_window : size(merged_data,2)
        [j,i] % show the progress in command window
        start = i;
        ending = i + time_window -1;
        curr = mean(merged_data(:,start:ending),2);

        figure(h_top);
        subplot(length(dataNames),numStates,counter);
        ft_plot_mesh(sourcespace, 'vertexcolor', curr);
        view(0,90);%top view

        figure(h_bottom);
        subplot(length(dataNames),numStates,counter);
        ft_plot_mesh(sourcespace, 'vertexcolor', curr);
        view(0,-90);%bottom view
        counter = counter + 1;
    end
end

%% save figures as png files
saveas(h_top,'TopView.fig'); % Caution: It can not be saved as png file by unknown reason.
saveas(h_bottom,'BottomView.fig');


