clc;
%clear all;
close all;

%addpath('C:/MyProject/fieldtrip-20130901');
addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

load sourcespace_template;
load vol_template;
load elec_biosemi;%elec_template;
load leadfield_biosemi;%leadfield_template;

%%
% load ../data/input/Wang/painEEG_clean_1_40Hz;
% load ../data/input/Wang/PainEEG/processedData_sub2__1_40_hz;
%load C:/MyProject/data/input/Liu_Ola/amarnath_resting.mat; % Data_Brain_Resting_1
load C:/MyProject/data/input/Liu_Ola/brandon-resting.mat; % data_Brain_Resting_2_brandon
% EEGclean_1_40Hz = EEG_data;

pattern = [];
%load pattern;
windowlength = 1000;
start = -1;
step = 4;

% 1. Reading the FC data
inputDir = '../data/input';
outputDir = '../data/output';
dirName = 'Liu_Ola';
pathName = [inputDir, filesep, dirName];
prefix = 'brandon-resting';%'amarnath_resting'; %'waterpain1';%'coldpressor2','brandon-resting'
suffix = '.bdf';
fileName = [prefix, suffix];
fullName = [pathName, filesep, fileName];
    
for i = start : 2 : 57%start+step-1 %57
    prestim = -i;
    poststim = -prestim + step;
    
    %% Processing of functional data
    % Preprocessing of MEG data
    % find the interesting segments of data
    cfg = [];
    cfg.dataset                 = fullName;       % name of CTF dataset  
    cfg.trialfun                = 'hx_trialfun_resting';
    cfg.trialdef.pre        = prestim;
    cfg.trialdef.post       = poststim;
    %cfg.trialdef.eventvalue     = 9;   % trigger value for fully congruent (FC)
    cfg = ft_definetrial(cfg);            
    
    % preprocess the data
    myChannels    = {'all','-M1','-M2','-LO1','-LO2','-IO1','-IO2','-EXG7','-EXG8','-Status'}; 
    cfg.channel = myChannels;
    % cfg.demean     = 'yes';
    % cfg.baselinewindow  = [-0.2 0];
    % cfg.lpfilter   = 'yes';                              % apply lowpass filter
    % cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

    dataFC_LP = ft_preprocessing(cfg);
%     dataFC_LP.fsample = 512;
%     tmp = dataFC_LP.time{1};
%     tmp = tmp*4;
%     dataFC_LP.time = {tmp};
    dataFC_LP.label = elec.label;
    
    % update trials with lowpass data
%     dataFC_LP = hx_update_trial_resting(dataFC_LP, Data_Brain_Resting_1);
    dataFC_LP = hx_update_trial_resting(dataFC_LP, data_Brain_Resting_2_brandon);
    dataFC_LP = hx_average_trial(dataFC_LP, windowlength);
    
    %save dataFC_LP dataFC_LP;

    %% 2. Reading the FIC data
%     tmp1 = dataFC_LP.trial{1};
%     tmp2 = zeros(size(tmp1));
%     dataFIC_LP = dataFC_LP;
%     dataFIC_LP.trial = {tmp2};
    
    %save dataFIC_LP dataFIC_LP;

    %% Averaging and noise-covariance estimation
    % load dataFC_LP;
    % load dataFIC_LP;
    cfg = [];
    cfg.covariance = 'yes';
    cfg.channel=myChannels;
    cfg.grad=elec;
    cfg.covariancewindow = [-prestim poststim];%[-inf 0]; %it will calculate the covariance matrix 
                                   % on the timepoints that are  
                                   % before the zero-time point in the trials
    tlckFC = ft_timelockanalysis(cfg, dataFC_LP);
    %tlckFIC = ft_timelockanalysis(cfg, dataFIC_LP);
    %save tlck tlckFC tlckFIC;

    %% Inverse solution
    % load tlck;

    cfg        = [];
    cfg.method = 'mne';
    cfg.channel=myChannels;
    cfg.grad   = elec;
    cfg.grid   = leadfield;
    cfg.vol    = vol;
    cfg.mne.prewhiten = 'yes';
    cfg.mne.lambda    = 3;
    cfg.mne.scalesourcecov = 'yes';
    sourceFC  = ft_sourceanalysis(cfg,tlckFC);
    %sourceFIC = ft_sourceanalysis(cfg, tlckFIC);

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
    %sdFIC = hx_sourcedescriptives(cfg, sourceFIC);

    sdDIFF = sdFC;
    %sdDIFF.avg.pow = sdFIC.avg.pow - sdFC.avg.pow;
    sdDIFF.tri = sourcespace.tri;

    %save sd sdFC sdFIC sdDIFF;
    %pattern = [pattern, mean(sdDIFF.avg.pow,2)];
%     pattern = [pattern, mean(abs(sdDIFF.avg.pow(:,1:end-windowlength)),2)];% discard the last 1000 point due to averaging issue
%     save pattern pattern;
    pattern = [pattern, mean(abs(sdDIFF.avg.pow),2)];%when there is no averaging
    save pattern pattern;
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
