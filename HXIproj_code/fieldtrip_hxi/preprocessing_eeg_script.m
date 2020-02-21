% preprocessing_eeg_script.m
% http://www.fieldtriptoolbox.org/example/preprocessing_eeg
% http://www.fieldtriptoolbox.org/example/getting_started_with_reading_raw_eeg_or_meg_data

clc;
%clear all;
close all;

addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

%% visualize the raw data
% cfg = [];
% cfg.dataset    = 'C:\MyProject\data\input\Peng\waterpain1.eeg';
% cfg.continuous = 'yes'; 
% cfg.channel    = {'1','2'};
% cfg.viewmode   = 'vertical';
% cfg.blocksize  = 1; % Length of data to display, in seconds
%  
% ft_databrowser(cfg);
%  
% set(gcf, 'Position',[1 1 1200 800])

%% Check if there are events. 
cfg = [];

% In the same folder you should have 3 files with the same filename and
% different suffixes: .vhdr, .eeg, .vmrk
% cfg.dataset = 'C:\MyProject\data\input\Peng\waterpain1.vhdr';
cfg.dataset = 'C:\MyProject\data\input\Peng\coldpressor2.vhdr';
cfg.headerformat='brainvision_vhdr';
cfg.trialdef.eventtype  = '?';
ft_definetrial(cfg);

% See results in command window. "event type" gives you useful information.
% the eventtype in the next step depends on the info in this step.

%% define trials using the events found
% case 1: Assume data are continuous, i.e., there are gaps between trials.
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialfun = 'hx_trialfun_general';
cfg.trialdef.pre  = 0; % 1 sec before stimulation
cfg.trialdef.post = 60; % 2 sec after stimulation
cfg = ft_definetrial(cfg);

% % case 2: Assume data are pseudo-continuous, i.e., there are no gaps between trials.
% cfg.trialdef.eventtype  = 'backpanel trigger';
% cfg.trialdef.eventvalue = 1;
% cfg.trialdef.prestim    = 0.2;
% cfg.trialdef.poststim   = 0.6;
% cfg = ft_definetrial(cfg); % now remember the output

%% artifact detection
% artifact_eog
% artifact_ecg
% rejectartifact

%% retrieve trials, filtering, re-referencing, and generate raw data
dataPRE = ft_preprocessing(cfg);
save dataPRE dataPRE

%% plot data for all channels
%load dataPRE

nTrials = length(dataPRE.trial);
nChannels = length(dataPRE.label);
nCol = 4;
nRow = 4;%round(nChannels/nCol + 0.5);

h=figure('units','normalized','outerposition',[0 0 1 1]);
for j=1:nTrials  % # of trials
    for ch=1:1 % nChannels % # of channels
        subplot(nRow, nCol, j); 
        plot(dataPRE.trial{j}(ch,:));
        %axis([0,2,-500,500])
        title(['Ch: ',dataPRE.label{ch} ', Trial: ' num2str(j)]);
    end
    %pause(1);
end
disp('All channels are shown.');

