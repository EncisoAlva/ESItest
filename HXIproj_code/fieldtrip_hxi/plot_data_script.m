%plot_data_script.m
% http://www.fieldtriptoolbox.org/tutorial/plotting


%% 
clc;
%clear all;
close all;

addpath('C:/MyProject/fieldtrip-20130901');
% addpath('C:/MyProject/fieldtrip-20151006');
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
cfg.dataset = 'C:\MyProject\data\input\Peng\waterpain1.vhdr';
cfg.headerformat='brainvision_vhdr';
cfg.trialdef.eventtype  = '?';
ft_definetrial(cfg);

% See results in command window. "event type" gives you useful information.
% the eventtype in the next step depends on the info in this step.

%% define trials using the events found
% case 1: Assume data are continuous, i.e., there are gaps between trials.
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialfun = 'hx_trialfun_general';
cfg.trialdef.pre  = 10; % 1 sec before stimulation
cfg.trialdef.post = 70; % 2 sec after stimulation
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
myChannels = {'18','19','51','52','53'};

for i = 1 : length(myChannels)
    ch = str2double(myChannels{i});
    figure;
    plot(dataPRE.trial{1}(ch,:),'b-');%baseline
    hold on; 
    rc_aver = (dataPRE.trial{3}(ch,:)+dataPRE.trial{7}(ch,:)+dataPRE.trial{11}(ch,:))/3;
    plot(rc_aver,'r-');%right cold average
    legend('Baseline','Right Cold');
    title(['Channel ', myChannels{i}, ' (Raw)']);
end

%%
load ../data/input/Wang/painEEG_clean_1_40Hz;
for i = 1 : length(myChannels)
    ch = str2double(myChannels{i});
    figure;
    ind = dataPRE.sampleinfo(1,:);
    plot(EEGclean_1_40Hz(ch,dataPRE.sampleinfo(1,1):dataPRE.sampleinfo(1,2)),'b-');%baseline
    hold on; 
    rc_aver = (EEGclean_1_40Hz(ch,dataPRE.sampleinfo(3,1):dataPRE.sampleinfo(3,2))...
        +EEGclean_1_40Hz(ch,dataPRE.sampleinfo(7,1):dataPRE.sampleinfo(7,2))...
        +EEGclean_1_40Hz(ch,dataPRE.sampleinfo(11,1):dataPRE.sampleinfo(11,2)))/3;
    plot(rc_aver,'r-');%right cold average
    legend('Baseline','Right Cold');
    title(['Channel ', myChannels{i}, ' (1-40 Hz)']);
end
