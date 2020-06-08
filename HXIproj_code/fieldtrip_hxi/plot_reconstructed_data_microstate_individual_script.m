% plot_reconstructed_data_microstate_individual_script.m
%
% This script saves each figure into one file. The user can combine them
% manually.
%
% Hongguang Xi, 11/11/2015.

clc;
clear all;
close all;

%%
%addpath('../fieldtrip-20130901');
addpath('../fieldtrip-20150911');
ft_defaults

load sourcespace_template; % default name is sourcespace
dataNames = {'recon_data_rw','recon_data_rc','recon_data_lw','recon_data_lc'};
numStates = 12; 

h_top = figure;
hold off;
h_bottom = figure;
hold off;

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
        fileName = [num2str(length(dataNames)),'_',num2str(numStates),'_',num2str(counter)];
        
        figure(h_top);
        ft_plot_mesh(sourcespace, 'vertexcolor', curr);
        view(0,90);%top view
        saveas(h_top,['TopView_',fileName,'.fig']); % Caution: It can not be saved as png file by unknown reason.
        
        figure(h_bottom);
        ft_plot_mesh(sourcespace, 'vertexcolor', curr);
        view(0,-90);%bottom view
        saveas(h_top,['BottomView_',fileName,'.fig']); % Caution: It can not be saved as png file by unknown reason.
        
        counter = counter + 1;
    end
end


