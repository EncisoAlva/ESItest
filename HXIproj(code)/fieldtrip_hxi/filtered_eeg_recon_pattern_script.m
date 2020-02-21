clc;
clear all;
close all;

%addpath('C:/MyProject/fieldtrip-20130901');
addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

load sourcespace_template;
load vol_template;
load elec_template;
load leadfield_template;

%%
load ../data/input/Wang/painEEG_clean_1_40Hz;
% load ../data/input/Wang/PainEEG/processedData_sub2__1_40_hz;
% EEGclean_1_40Hz = EEG_data;

pattern = [];
%load pattern;
windowlength = 1000;
start = 0;
step = 3;

% 1. Reading the FC data
inputDir = '../data/input';
outputDir = '../data/output';
dirName = 'Peng';
pathName = [inputDir, filesep, dirName];
prefix = 'waterpain1'; %'waterpain1';%'coldpressor2'
suffix = '.vhdr';
fileName = [prefix, suffix];
fullName = [pathName, filesep, fileName];
    
for i = start : step : 57%start+step-1 %57
    prestim = -i;
    poststim = -prestim + step;
    
    %% Processing of functional data
    % Preprocessing of MEG data
    % find the interesting segments of data
    cfg = [];
    cfg.dataset                 = fullName;       % name of CTF dataset  
    cfg.trialdef.eventtype      = 'Stimulus';
    cfg.trialfun                = 'hx_trialfun_general';
    cfg.trialdef.pre        = prestim;
    cfg.trialdef.post       = poststim;
    %cfg.trialdef.eventvalue     = 9;   % trigger value for fully congruent (FC)
    cfg = ft_definetrial(cfg);            

    % remove the trials that have artifacts from the trl
    % cfg.trl([1, 3, 4, 5, 7, 8, 9, 11, 12, 13],:) = []; 
    % cfg.trl([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],:) = []; % baseline
    %cfg.trl([1, 2, 4, 5, 6, 8, 9, 10, 12, 13],:) = []; % right cold
    %cfg.trl([1, 2, 3, 4, 6, 7, 8, 10, 11, 12],:) = []; % left cold
    cfg.trl([1, 2, 3, 5, 6, 7, 9, 10, 11, 13],:) = []; % left warm
    
    % preprocess the data
    cfg.channel    = {'all'};       % read all MEG channels except MLP31 and MLO12
    % cfg.demean     = 'yes';
    % cfg.baselinewindow  = [-0.2 0];
    % cfg.lpfilter   = 'yes';                              % apply lowpass filter
    % cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

    dataFC_LP = ft_preprocessing(cfg);

    % update trials with lowpass data
    dataFC_LP = hx_update_trial(dataFC_LP, EEGclean_1_40Hz);
    %dataFC_LP = hx_average_trial(dataFC_LP, windowlength);
    
    %save dataFC_LP dataFC_LP;

    %% 2. Reading the FIC data
    % find the interesting segments of data
    cfg = [];
    cfg.dataset                 = fullName;       % name of CTF dataset  
    cfg.trialdef.eventtype      = 'Stimulus';
    cfg.trialfun                = 'hx_trialfun_general';
    cfg.trialdef.pre        = prestim;
    cfg.trialdef.post       = poststim;
    %cfg.trialdef.eventvalue     = 3; % trigger value for fully incongruent (FIC)
    cfg = ft_definetrial(cfg);            

    % remove the trials that have artifacts from the trl
    cfg.trl([1, 3, 4, 5, 7, 8, 9, 11, 12, 13],:) = []; % right warm
   %cfg.trl([1, 2, 4, 5, 6, 8, 9, 10, 12, 13],:) = []; % right cold
   % cfg.trl([1, 2, 3, 5, 6, 7, 9, 10, 11, 13],:) = []; % left warm

    % preprocess the data
    cfg.channel    = {'all'};  % read all MEG channels except MLP31 and MLO12
    % cfg.demean     = 'yes';
    % cfg.baselinewindow  = [-0.2 0];
    % cfg.lpfilter   = 'yes';                              % apply lowpass filter
    % cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

    dataFIC_LP = ft_preprocessing(cfg); 

    % update trials with lowpass data
    dataFIC_LP = hx_update_trial(dataFIC_LP, EEGclean_1_40Hz);
    %dataFIC_LP = hx_average_trial(dataFIC_LP, windowlength);
    
    %save dataFIC_LP dataFIC_LP;

    %% Averaging and noise-covariance estimation
    % load dataFC_LP;
    % load dataFIC_LP;
    cfg = [];
    cfg.covariance = 'yes';
    cfg.channel={'all'};
    cfg.grad=elec;
    %cfg.covariancewindow = [-prestim poststim];%[-inf 0]; %it will calculate the covariance matrix 
                                   % on the timepoints that are  
                                   % before the zero-time point in the trials
    tlckFC = ft_timelockanalysis(cfg, dataFC_LP);
    tlckFIC = ft_timelockanalysis(cfg, dataFIC_LP);
    %save tlck tlckFC tlckFIC;

    %% Inverse solution
    % load tlck;

    cfg        = [];
    cfg.method = 'mne';
    cfg.channel={'all'};
    cfg.grad   = elec;
    cfg.grid   = leadfield;
    cfg.vol    = vol;
    cfg.mne.prewhiten = 'yes';
    cfg.mne.lambda    = 3;
    cfg.mne.scalesourcecov = 'yes';
    sourceFC  = ft_sourceanalysis(cfg,tlckFC);
    sourceFIC = ft_sourceanalysis(cfg, tlckFIC);

    %save source sourceFC sourceFIC;

    %% Visualization
    % show the diffenrence of the two conditions
    cfg = [];
    %cfg.projectmom = 'yes';
    if prestim <= 0
        cfg.baselinewindow = [-prestim poststim];
    else
        cfg.baselinewindow = [-inf 0];
    end
    sdFC = hx_sourcedescriptives(cfg,sourceFC);
    sdFIC = hx_sourcedescriptives(cfg, sourceFIC);

    sdDIFF = sdFIC;
    sdDIFF.avg.pow = sdFIC.avg.pow - sdFC.avg.pow;
    sdDIFF.tri = sourcespace.tri;

    %save sd sdFC sdFIC sdDIFF;
    %pattern = [pattern, mean(sdDIFF.avg.pow,2)];
%     pattern = [pattern, mean(abs(sdDIFF.avg.pow(:,1:end-windowlength)),2)];% discard the last 1000 point due to averaging issue
%     save pattern pattern;
    pattern = [pattern, mean(abs(sdDIFF.avg.pow),2)];%when there is no averaging
%     outfile = ['pattern_',num2str(i)];
%     save(outfile, 'pattern');

    %%
%     cfg = [];
%     cfg.maskparameter = 'pow';
%     figure;
%     ft_sourcemovie(cfg,sdDIFF);
    
    %% plot a time point
    % load source;
    % load sourcespace;

    % bnd.pnt = sourcespace.pnt;
    % bnd.tri = sourcespace.tri;
    % m=sourceFIC.avg.pow(:,450); % plotting the result at the 450th time-point that is 
    %                          % 500 ms after the zero time-point
    % ft_plot_mesh(bnd, 'vertexcolor', m);
    i
end
pattern_final = mean(pattern,2);
save pattern_final pattern_final;

%% plot
figure;
ft_plot_mesh(sourcespace, 'vertexcolor', pattern_final);
view(0,90);%top view

figure;
ft_plot_mesh(sourcespace, 'vertexcolor', pattern_final);
view(0,-90);%bottom view

%%
% pattern2 = mean(pattern,2);
% bnd.pnt = sourcespace.pnt;
% bnd.tri = sourcespace.tri;
% figure;
% ft_plot_mesh(bnd, 'vertexcolor', pattern2);
% view(0,90);%top view
% 
% figure;
% ft_plot_mesh(bnd, 'vertexcolor', pattern2);
% view(0,-90);%bottom view
%%
% %% check which region is of interest
% % mid1 =2480;
% % mid2 =2490;
% % pattern3 = [zeros(mid1-1,1);pattern2(mid1:mid2);zeros(8196-mid2,1)];
% % bnd.pnt = sourcespace.pnt;
% % bnd.tri = sourcespace.tri;
% % figure;
% % ft_plot_mesh(bnd, 'vertexcolor', pattern3);
% % view(0,90);
% 
% %% thelamus
% pnt = sourcespace.pnt;
% x=pnt(:,1);
% y=pnt(:,2);
% z=pnt(:,3);
% 
% % ind1 = x>=-45 & x<=-20;
% % ind2 = y>=-10 & y<=10;
% % ind3 = z>=-50 & z<=-30;
% ind1 = x>=-50 & x<=-14;
% ind2 = y>=-20 & y<=14;
% ind3 = z>=-48 & z<=-27;
% 
% ind4 = ind1.*ind2.*ind3;
% ind = find(ind4==1);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = pattern2(ind);
% bnd.pnt = sourcespace.pnt;
% bnd.tri = sourcespace.tri;
% figure;
% ft_plot_mesh(bnd, 'vertexcolor', pattern3);
% view(0,90);%top view
% 
% %% plot the signal in the specified region
% my = figure;
% % mid1 =6000;
% % mid2 =7500;
% % signal = abs(sdDIFF.avg.pow(mid1:mid2,:));
% mid=[6550:6575,6600:6625,6700:6725,6740:6750,6790:6800,6840:6850,6880:6890];%thalamus
% ind=[2000:3000];
% signal = abs(sdDIFF.avg.pow(ind,1:end-windowlength));
% signal_average = mean(signal,1);
% plot(signal_average,'r-');
% title('Activities at thalamus');
% 
% %% left middle
% pnt = sourcespace.pnt;
% x=pnt(:,1);
% y=pnt(:,2);
% z=pnt(:,3);
% 
% ind1 = x>=-58 & x<=-30;
% %ind2 = y>=4 & y<=35;
% ind2 = y>=1 & y<=57;
% ind3 = z>=-80 & z<=-50;
% 
% ind4 = ind1.*ind2.*ind3;
% ind = find(ind4==1);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = pattern2(ind);
% bnd.pnt = sourcespace.pnt;
% bnd.tri = sourcespace.tri;
% figure;
% ft_plot_mesh(bnd, 'vertexcolor', pattern3);
% view(0,90);% top view
% 
% %% plot the signal in the specified region
% figure(my);
% hold on;
% % mid1 =6000;
% % mid2 =7500;
% % signal = abs(sdDIFF.avg.pow(mid1:mid2,:));
% mid=[6550:6575,6600:6625,6700:6725,6740:6750,6790:6800,6840:6850,6880:6890];%thalamus
% signal = abs(sdDIFF.avg.pow(ind,1:end-windowlength));
% signal_average = mean(signal,1);
% plot(signal_average);
% title('Activities at left middle part');
% legend('Thalamus','MidLeft');
% % save sdDIFF sdDIFF;
% 
