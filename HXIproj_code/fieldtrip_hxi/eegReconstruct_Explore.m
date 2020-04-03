% Source reconstruction from EEG data using FieldTrip toolbox
% Original by Dr Xi

%% CHANGELOG
% 2019-09-17
%   JC.EA started adding comments for his own project
%   FieldTrip changed to version 20190615
%   Changing to local routes

%% fresh start
clc;
clear all;
close all;

%% FieldTrip
cd ../fieldtrip-20190615
addpath(pwd);
cd ../fieldtrip_hxi

ft_defaults    % initialization

%% Load data
load sourcespace_template;
load vol_template;
load elec_template;
load leadfield_template;

% look the points of sourcespace
scatter3(sourcespace.pnt(:,1),sourcespace.pnt(:,2),sourcespace.pnt(:,3),'filled')

% original points in sourcespace, a lot of them
scatter3(sourcespace.orig.pnt(:,1),sourcespace.orig.pnt(:,2),sourcespace.orig.pnt(:,3),.1,'filled')

% boundaries of the volume conductor model
scatter3(vol.bnd(1).pnt(:,1),vol.bnd(1).pnt(:,2),vol.bnd(1).pnt(:,3))
scatter3(vol.bnd(2).pnt(:,1),vol.bnd(2).pnt(:,2),vol.bnd(2).pnt(:,3))
scatter3(vol.bnd(3).pnt(:,1),vol.bnd(3).pnt(:,2),vol.bnd(3).pnt(:,3))

% position of channels
scatter3(elec.chanpos(:,1),elec.chanpos(:,2),elec.chanpos(:,3),'r','filled')
hold on
scatter3(elec.elecpos(:,1),elec.elecpos(:,2),elec.elecpos(:,3),'b','filled')

scatter3(elec.chanpos(:,1)-elec.elecpos(:,1), ...
         elec.chanpos(:,2)-elec.elecpos(:,2), ...
         elec.chanpos(:,3)-elec.elecpos(:,3),'r','filled')

% leadfield
A = leadfield.leadfield(1,1);
A = A{1,1};
scatter3(A(:,1),A(:,2),A(:,3))
hold on
A = leadfield.leadfield(1,2);
A = A{1,1};
scatter3(A(:,1),A(:,2),A(:,3))

A = leadfield.leadfield(1,1);
A = A{1,1};
scatter3(A(:,1),A(:,2),A(:,3))
hold on
for(i = 2:8000)
    A = leadfield.leadfield(1,i);
    A = A{1,1};
    scatter3(A(:,1),A(:,2),A(:,3))
end

%% Processing of functional data

%% 0. Metadata
cd ../../data
inputDir  = [ pwd, filesep, 'input'];
outputDir = [ pwd, filesep, 'output'];
cd ../code/fieldtrip_hxi
dirName   = 'Peng';
pathName  = [inputDir, '/', dirName];
prefix    = 'waterpain1';
suffix    = '.vhdr';
fileName  = [prefix, suffix];
fullName  = [pathName, '/', fileName];

% Select segments
prestim  = 0;
poststim = -prestim + 3;

%% 1. Reading the FC data
cfg = [];
cfg.dataset            = fullName;       % name of CTF dataset  
cfg.trialfun           = 'hx_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.pre       = prestim;
cfg.trialdef.post      = poststim;
%cfg.trialdef.eventvalue = 9;   % trigger value for fully congruent (FC)
cfg = ft_definetrial(cfg);
cfg.channel = {'all'}; % read all MEG channels except MLP31 and MLO12

% Remove trials with artifacts
cfg.trl([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],:) = []; 

% Preprocess
dataFC_LP = ft_preprocessing(cfg);

% Look at the plots
plot(dataFC_LP.time{1}',dataFC_LP.trial{1,1}(1,:)')
for(i = 1:64)
    figure()
    plot(dataFC_LP.time{1}',dataFC_LP.trial{1,1}(i,:)')
end

%% 2. Reading the FIC data (look the trials)
cfg = [];
cfg.dataset            = fullName;       % name of CTF dataset  
cfg.trialfun           = 'hx_trialfun_general';
cfg.trialdef.eventtype = 'Stimulus';
cfg.trialdef.pre       = prestim;
cfg.trialdef.post      = poststim;
%cfg.trialdef.eventvalue = 3; % trigger value for fully incongruent (FIC)
cfg = ft_definetrial(cfg);            
cfg.channel = {'all'};  % read all MEG channels except MLP31 and MLO12

% Remove trials with artifacts
cfg.trl([1, 2, 4, 5, 6, 8, 9, 10, 12, 13],:) = []; % right cold

% Preprocess
% cfg.demean         = 'yes';
% cfg.baselinewindow = [-0.2 0];
% cfg.lpfilter       = 'yes';    % apply lowpass filter
% cfg.lpfreq         = 35;       % lowpass at 35 Hz.
dataFIC_LP = ft_preprocessing(cfg); 

% Look at the plots
plot(dataFIC_LP.time{1}',dataFC_LP.trial{1,1})
plot(dataFC_LP.trial{1,1}')

%% 3. Averaging and noise-covariance estimation
cfg = [];
cfg.covariance = 'yes';
cfg.channel    = {'all'};
cfg.grad       = elec;
%cfg.covariancewindow = ...
%   [-prestim poststim];
%   [-inf 0];                 %it will calculate the covariance matrix 
                             % on the timepoints that are  
                             % before the zero-time point in the trials
tlckFC  = ft_timelockanalysis(cfg, dataFC_LP);
tlckFIC = ft_timelockanalysis(cfg, dataFIC_LP);

% look at the plots
plot(tlckFC.time, tlckFC.avg')
plot(tlckFIC.time,tlckFIC.avg')
plot(tlckFC.avg)
plot(tlckFIC.avg)

tlckFC.corr = tlckFC.cov;
for(i = 1:64)
    tlckFC.corr(i,:) = tlckFC.corr(i,:)./(ones(64)*tlckFC.corr(i,i));
end
pcolor(tlckFC.cov)
pcolor(tlckFC.corr)

%% 4. Inverse solution
cfg = [];
cfg.method  = 'mne';
cfg.channel = {'all'};
cfg.grad    = elec;
cfg.grid    = leadfield;
cfg.vol     = vol;
cfg.mne.prewhiten      = 'yes';
cfg.mne.lambda         = 3;
cfg.mne.scalesourcecov = 'yes';
sourceFC  = ft_sourceanalysis(cfg, tlckFC);
sourceFIC = ft_sourceanalysis(cfg, tlckFIC);

scatter3(sourceFC.pos(:,1),sourceFC.pos(:,2),sourceFC.pos(:,3))

i=1;
scatter3(sourceFC.pos(i,1),sourceFC.pos(i,2),sourceFC.pos(i,3),'filled')
hold on
scatter3(sourceFC.leadfield{1,1}(:,1),sourceFC.leadfield{1,1}(:,2),sourceFC.leadfield{1,1}(:,2))
hold off

for(i=1:100)
    figure()
    scatter3(sourceFC.pos(i,1),sourceFC.pos(i,2),sourceFC.pos(i,3),'filled')
    hold on
    scatter3(sourceFC.leadfield{1,1}(:,1),sourceFC.leadfield{1,1}(:,2),sourceFC.leadfield{1,1}(:,2))
end

%% 5. Plot

figure;
ft_plot_mesh(vol.bnd(3),'facecolor','none');
figure;
ft_plot_mesh(vol.bnd(2),'facecolor','none');
figure;
ft_plot_mesh(vol.bnd(1),'facecolor','none');


ft_plot_mesh(vol.bnd(1), 'facecolor',[0.2 0.2 0.2], 'facealpha', 0.3, 'edgecolor', [1 1 1], 'edgealpha', 0.05);
hold on;
ft_plot_mesh(vol.bnd(2),'edgecolor','none','facealpha',0.4);
hold on;
ft_plot_mesh(vol.bnd(3),'edgecolor','none','facecolor',[0.4 0.6 0.4]);


figure;
% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor','none','facealpha',0.8,'facecolor',[0.6 0.6 0.8]);
hold on;
% electrodes
ft_plot_sens(elec,'style', 'sk');


cfg = [];
cfg.roi = 'all';
mask = ft_volumelookup(cfg,vol);

%% Differences between conditions
cfg = [];
%cfg.projectmom = 'yes';
if prestim <= 0
    cfg.baselinewindow = [-prestim poststim];
else
    cfg.baselinewindow = [-inf 0];
end
sdFC  = hx_sourcedescriptives(cfg,sourceFC);
sdFIC = hx_sourcedescriptives(cfg, sourceFIC);

sdDIFF         = sdFIC;
sdDIFF.avg.pow = sdFIC.avg.pow - sdFC.avg.pow;
sdDIFF.tri     = sourcespace.tri;

%% Movie
% cfg = [];
% cfg.maskparameter = 'pow';
% figure;
% ft_sourcemovie(cfg,sdDIFF);

%% plot a time point
% load source;
% load sourcespace;

% bnd.pnt = sourcespace.pnt;
% bnd.tri = sourcespace.tri;
% m=sourceFIC.avg.pow(:,450); % plotting the result at the 450th time-point that is 
%                          % 500 ms after the zero time-point
% ft_plot_mesh(bnd, 'vertexcolor', m);

%% Plot average in big region
% figure;
% mid1 =6000;
% mid2 =7500;
% signal = abs(sdDIFF.avg.pow(mid1:mid2,:));
% signal_average = mean(signal,1);
% plot(signal_average);
% title('Activities at left middle part');

