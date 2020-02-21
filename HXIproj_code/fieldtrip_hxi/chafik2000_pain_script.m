clc;
%clear all;
close all;

%addpath('C:/MyProject/fieldtrip-20130901');
addpath('C:/MyProject/fieldtrip-20150911');
%addpath('C:/MyProject/fieldtrip-20161001');
ft_defaults

load sourcespace_template;
load vol_template;
load elec_template;
load leadfield_template;

%%
%load ../data/input/Wang/painEEG_clean_1_40Hz;
load ../data/input/Wang/PainEEG/processedData_sub2__1_40_hz;%EEG_data
%load ../data/input/Peng/sub2_1_40_ICA_adj;%sub2_1_40_ICA_adj
EEGclean_1_40Hz = EEG_data;

pattern = [];
%load pattern;
recon_mat = [];
windowlength = 1000;
start = -2;
step = 5;

source_pnt = sourcespace.pnt;
source_tri = sourcespace.tri;

pow_pain = zeros(size(source_pnt,1),1);
    
% 1. Reading the FC data
inputDir = '../data/input';
outputDir = '../data/output';
dirName = 'Peng';
pathName = [inputDir, filesep, dirName];
prefix = 'coldpressor2'; %'waterpain1';%'coldpressor2'
suffix = '.vhdr';
fileName = [prefix, suffix];
fullName = [pathName, filesep, fileName];
    
for i = start : 2 : -1%start+step-1 %57
    prestim = -i;
    poststim = -prestim + step;
    
    %% Processing of functional data
    % Preprocessing of MEG data
    % find the interesting segments of data
%     cfg = [];
%     cfg.dataset                 = fullName;       % name of CTF dataset  
%     cfg.trialdef.eventtype      = 'Stimulus';
%     cfg.trialfun                = 'hx_trialfun_general';
%     cfg.trialdef.pre        = prestim;
%     cfg.trialdef.post       = poststim;
%     %cfg.trialdef.eventvalue     = 9;   % trigger value for fully congruent (FC)
%     cfg = ft_definetrial(cfg);            
% 
%     % remove the trials that have artifacts from the trl
%     % cfg.trl([1, 3, 4, 5, 7, 8, 9, 11, 12, 13],:) = []; 
%      cfg.trl([2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],:) = []; % baseline
%     %cfg.trl([1, 2, 4, 5, 6, 8, 9, 10, 12, 13],:) = []; % right cold
%     %cfg.trl([1, 2, 3, 4, 6, 7, 8, 10, 11, 12],:) = []; % left cold
%     %cfg.trl([1, 2, 3, 5, 6, 7, 9, 10, 11, 13],:) = []; % left warm
%     
%     % preprocess the data
%     cfg.channel    = {'all'};       % read all MEG channels except MLP31 and MLO12
%     % cfg.demean     = 'yes';
%     % cfg.baselinewindow  = [-0.2 0];
%     % cfg.lpfilter   = 'yes';                              % apply lowpass filter
%     % cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.
% 
%     dataFC_LP = ft_preprocessing(cfg);
% 
%     % update trials with lowpass data
%     dataFC_LP = hx_update_trial(dataFC_LP, EEGclean_1_40Hz);
%     dataFC_LP = hx_average_trial(dataFC_LP, windowlength);
%     
%     %save dataFC_LP dataFC_LP;

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
    %cfg.trl([2, 3, 4, 6, 7, 8, 10, 11, 12],:) = []; % right warm
    %cfg.trl([1, 3, 4, 5, 7, 8, 9, 11, 12],:) = []; % right cold
    %cfg.trl([1, 2, 4, 5, 6, 8, 9, 10, 12],:) = []; % left warm
    cfg.trl([1, 2, 3, 5, 6, 7, 9, 10, 11],:) = []; % left cold
    
    % preprocess the data
    cfg.channel    = {'all'};  % read all MEG channels except MLP31 and MLO12
    % cfg.demean     = 'yes';
    % cfg.baselinewindow  = [-0.2 0];
    % cfg.lpfilter   = 'yes';                              % apply lowpass filter
    % cfg.lpfreq     = 35;                                 % lowpass at 35 Hz.

    dataFIC_LP = ft_preprocessing(cfg); 
    freq=dataFIC_LP.fsample;
    
    % update trials with lowpass data
    dataFIC_LP = hx_update_trial(dataFIC_LP, EEGclean_1_40Hz);
    dataFIC_LP = hx_average_trial(dataFIC_LP, windowlength);
    
    %save dataFIC_LP dataFIC_LP;

    %%
    dataFIC_LP_trials = dataFIC_LP.trial;
    dataFIC_LP_merged = 0;
    for t = 1 : length(dataFIC_LP_trials)
        dataFIC_LP_merged = dataFIC_LP_merged + dataFIC_LP_trials{t};
    end
    dataFIC_LP_merged = dataFIC_LP_merged(:,2001:4000)/length(dataFIC_LP_trials);
    
    elec_ind = [1,33,3,42,12,51,23,60,29,30,31,64,27,55,16,45,7,36,2];
    data_circle = dataFIC_LP_merged(elec_ind,:);
    
    for w = 1 : size(data_circle,2)
        curr_data = data_circle(:,w);
        
        elec_pos_all = elec.elecpos;
        elec_pos = elec_pos_all(elec_ind,:);

        [r_head,theta] = cartesian2polar_2d(elec_pos(:,1:2));
        z = mean(elec_pos(:,3))/100;
        M = length(theta);
        r=1;% when plot the data we need use r_head
        beta = [];

        M_romberg = 10;
        for j = 1 : 2*M-1
            R = measure_beta_romberg_pain(r,j,0,2*pi,M_romberg,theta,curr_data);
            beta(end+1) = R(M_romberg,M_romberg);
        end

        Z1 = getZ(beta(1:2*M-1));

        tol = .3; % the tolerance is very empiracal and significantly affects the estimate of the rank
        m_est = rank(Z1,tol)

        % force the estimated number of sources to be true value
        %m_est = 3;

        %% estimate the positions of sources
        Z1 = getZ(beta(1:2*m_est-1));
        Z2 = getZ(beta(2:2*m_est));
        T = Z2 * inv(Z1);%Z1\Z2
        S_est = eig(T)

        %% estimate the moments of sources 
        S_est_mat = vander(S_est);
        S_est_mat2 = fliplr(S_est_mat);
        S_est_mat3 = transpose(S_est_mat2);
        b = Z1(:,1);
        p_est = inv(S_est_mat3) * b

        %% plot
%         figure;
%         circle(0,0,r);
%         hold on;

        S_est_x = real(S_est);
        S_est_y = imag(S_est);

%         plot(S_est_x,S_est_y,'bo');

        p_est_x = real(p_est);
        p_est_y = imag(p_est);

%         for q = 1 : size(S_est_x,1)
%             plot([S_est_x(q);S_est_x(q)+p_est_x(q)/20],[S_est_y(q);S_est_y(q)+p_est_y(q)/20],'g-');
%         end

%         xlabel('X');
%         ylabel('Y');
%         title(['Right Hand, Cold Water']);

        %% from 2D position to 3D grid
        for q = 1 : length(S_est_x)
            currS = [S_est_x(q),S_est_y(q),z]/10;
            currS_mat = repmat(currS,length(source_pnt),1);
            dist = sum((currS_mat-source_pnt).^2,2);
            [minDist, minInd] = min(dist)
            pow_pain(minInd,w) = pow_pain(minInd)+sqrt(p_est_x(q)^2+p_est_y(q)^2);
        end
    %     figure;
    %     ft_plot_mesh(sourcespace, 'vertexcolor', pow_pain);
    %     view(0,90);%top view
    % 
    %     figure;
    %     ft_plot_mesh(sourcespace, 'vertexcolor', pow_pain);
    %     view(0,-90);%bottom view

    end
    

    
    
    
    
    
    
    
    %% Averaging and noise-covariance estimation
%     % load dataFC_LP;
%     % load dataFIC_LP;
%     cfg = [];
%     cfg.covariance = 'yes';
%     cfg.channel={'all'};
%     cfg.grad=elec;
%     %cfg.covariancewindow = [-prestim poststim];%[-inf 0]; %it will calculate the covariance matrix 
%                                    % on the timepoints that are  
%                                    % before the zero-time point in the trials
%     %tlckFC = ft_timelockanalysis(cfg, dataFC_LP);
%     tlckFIC = ft_timelockanalysis(cfg, dataFIC_LP);
%     %save tlck tlckFC tlckFIC;
% 
    %% Inverse solution
%     % load tlck;
% 
%     cfg        = [];
%     cfg.method = 'mne';
%     cfg.channel={'all'};
%     cfg.grad   = elec;
%     cfg.grid   = leadfield;
%     cfg.vol    = vol;
%     cfg.mne.prewhiten = 'yes';
%     cfg.mne.lambda    = 3;
%     cfg.mne.scalesourcecov = 'yes';
%     %sourceFC  = ft_sourceanalysis(cfg,tlckFC);
%     sourceFIC = ft_sourceanalysis(cfg, tlckFIC);
% 
%     %save source sourceFC sourceFIC;

    %% Visualization
%     % show the diffenrence of the two conditions
%     cfg = [];
%     %cfg.projectmom = 'yes';
%     if prestim <= 0
%         cfg.baselinewindow = [-prestim poststim];
%     else
%         cfg.baselinewindow = [-inf 0];
%     end
%     %sdFC = hx_sourcedescriptives(cfg,sourceFC);
%     sdFIC = hx_sourcedescriptives(cfg, sourceFIC);
% 
%     sdDIFF = sdFIC;
%     recon = sdFIC.avg.pow;
%     recon = recon(:,1+freq:end-freq);
%     recon_mat = [recon_mat, recon];
%     sdDIFF.avg.pow = recon;
%     sdDIFF.tri = sourcespace.tri;
% 
%     %save sd sdFC sdFIC sdDIFF;
%     %pattern = [pattern, mean(sdDIFF.avg.pow,2)];
% %     pattern = [pattern, mean(abs(sdDIFF.avg.pow(:,1:end-windowlength)),2)];% discard the last 1000 point due to averaging issue
% %     save pattern pattern;
%     pattern = [pattern, mean(abs(recon),2)];%when there is no averaging
%     save pattern pattern;
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
pattern_final = mean(pow_pain,2);
save pattern_final pattern_final;
save recon_mat recon_mat;

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
