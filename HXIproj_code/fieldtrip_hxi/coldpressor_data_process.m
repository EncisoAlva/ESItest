addpath('C:\MyProject/fieldtrip_yliu/fieldtrip-20150911');
ft_defaults

%%
cd C:\MyProject\data\input\Peng; 
headerfile = 'coldpressor.vhdr';

cfg = [];
cfg.trialdef.eventtype='SyncStatus'; %'New Segment' 'Response' 'SyncStatus' 
cfg.trialdef.eventvalue='Sync On'; % 'R128', 'Sync On'
cfg.trialfun     = 'ft_trialfun_general';
%ft_trialfun_general
cfg.headerfile   = headerfile;

cfg.trialdef.triallength = 2; %duration in seconds (can be Inf)
cfg.trialdef.ntrials     = 500; %number of trials sbu1:506 sub4 207

cfg = ft_definetrial(cfg);

cfg.method='trial'; %'channel'
cfg.demean = 'yes';

%This function will call ft_read_data
%ft_read_data will call read_brainvision_eeg
%    fseek(fid, hdr.NumberOfChannels*samplesize*(begsample-1), 'cof');
%    dat = fread(fid, [hdr.NumberOfChannels, (endsample-begsample+1)],
%    sampletype);  This will read in a 32*10000 matrix in column order
dataPRE = ft_preprocessing(cfg);
save dataPRE dataPRE

%%
%-------------Plot all the 32 channels for  visual inspection-------------
load dataPRE
%%
h=figure('units','normalized','outerposition',[0 0 1 1]);
for j=1:1  %1:500
    for ch=1:31
        subplot(4,8,ch); plot(dataPRE.time{j}, dataPRE.trial{j}(ch,:));
        axis([0,2,-500,500])
        title([dataPRE.label{ch} ' trial=' num2str(j)]);
    end
    pause(1);
end
%%
h=figure('units','normalized','outerposition',[0 0 1 1]);
for ch=1:1
    dataPREAllTime = [];
    dataPREAllTrial = [];
    NTrials = 10;
    Start = 140;
    for j=Start:Start+NTrials-1  %1:500
        dataPREAllTime = [ dataPREAllTime 2*(j-1)+dataPRE.time{j} ];
        dataPREAllTrial = [ dataPREAllTrial dataPRE.trial{j}(ch,:)];
    end
    plot(dataPREAllTime, dataPREAllTrial,'color',[ch/31 mod(ch,3)/3 mod(ch,5)/5]);
    axis([2*(Start-1),2*(Start-1+NTrials),-500,500])
    hold on
end
%% 输出某个时间段Fp1的值，用来手工查找波峰
figure(1)
NTrials = 5;
for Start = 160:260
    for ch=1:2
        dataPREAllTime = [];
        dataPREAllTrial = [];
        for j=Start:Start+NTrials-1  %1:500
            dataPREAllTime = [ dataPREAllTime 2*(j-1)+dataPRE.time{j} ];
            dataPREAllTrial = [ dataPREAllTrial dataPRE.trial{j}(ch,:)];
        end
        subplot(2,1,ch);
        plot(dataPREAllTime, dataPREAllTrial,'color',[ch/31 mod(ch,3)/3 mod(ch,5)/5]);
        axis([2*(Start-1),2*(Start-1+NTrials),-500,500])
        grid on
    end
    pause(1)
end
%% 计算所列时间窗口的平均值，保存在trial 1中，在epiepitc_data_process_batch.m中设置trial=1进行重构
dataLength = 10000;
numChannels = 31;
plotChannel = 1;
%%Seizure period avg504-514
% AvgTimeWindows = [ 
%     502.47 502.75
%     503.32 503.7
%     506.62 507.18
%     507.18 507.56
%     508.05 508.6
%     510.3 510.65
%     514.45 514.88
%     514.88 515.22
%     ];
%Seizure period
% AvgTimeWindows = [ 
%     466.61 467.03
%     467.03 467.53
%     467.53 467.97
%     ];
%Seizure period (peaks)
% AvgTimeWindows = [ 
%     492.3 492.47
%     492.7 492.85
%     493.15 493.3
%     493.7 493.9
%     494.3 494.45
%     494.78 495
%     495.42 495.57
%     ];
%Rest period
% AvgTimeWindows = [ 
%     490.37 490.6
%     490.6 490.75
%     491.1 491.3
%     491.5 491.65
%     ];

%Seizure period (valley)
% AvgTimeWindows = [ 
%     492.5 492.7
%     492.9 493.15
%     493.42 493.6
%     494.47 494.7
%     495.0 495.3
%     495.55 495.8
%     ];
%Seizure period (increasing)
AvgTimeWindows = [ 
    492.1 492.35
    492.6 492.75
    493.1 493.25
    493.5 493.78
    494.28 494.38
    494.65 494.9
    495.35 495.5
    ];
%Seizure period (decreasing)
% AvgTimeWindows = [ 
%     492.35 492.6
%     492.75 493.05
%     493.25 493.5
%     493.78 493.98
%     494.38 494.58
%     494.9 495.1
%     495.5 495.72
%     ];
blockNumbers = ceil(AvgTimeWindows./2)
blockSegIdx = ceil(dataLength*(AvgTimeWindows./2 - floor(AvgTimeWindows./2)))
figure(2)
avgInterp = zeros(numChannels,dataLength);
for i=1:size(blockNumbers,1)
    if blockNumbers(i,1)==blockNumbers(i,2)
        extractedData = dataPRE.trial{blockNumbers(i,1)}(:,blockSegIdx(i,1):blockSegIdx(i,2));
    else
        tmp = dataPRE.trial{blockNumbers(i,1)}(:,blockSegIdx(i,1):dataLength);
        extractedData = [tmp dataPRE.trial{blockNumbers(i,2)}(:,1:blockSegIdx(i,2))];
    end
    for ch=1:numChannels %interplate all channels
        %plot(extractedData(ch,:))
        xi = linspace(1,size(extractedData(ch,:),2),dataLength);
        interpData = interp1(extractedData(ch,:),xi);
        avgInterp(ch,:) = avgInterp(ch,:) + interpData;
        if ch == plotChannel
            plot(interpData)
        end
        hold on
    end
end
avgInterp = avgInterp/size(blockNumbers,1);
plot(avgInterp(plotChannel,:),'r','LineWidth',3);
%update dataPRE.trial{1} for reconstruction purpose
dataPRE.trial{1} = avgInterp;



%%
%--------------Averaging and noise-covariance estimation----------------
load dataPRE;
%%
cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = 'all'; %[-inf 0]; %it will calculate the covariance matrix 
                                   % on the timepoints that are  
                                   % before the zero-time point in the trials
cfg.trials = 351:351; %Average over these trials
tlck = ft_timelockanalysis(cfg, dataPRE);
save tlck tlck;

h=figure('units','normalized','outerposition',[0 0 1 1]);
for ch=1:32
    subplot(4,8,ch); plot(tlck.time, tlck.avg(ch,:));
    axis([0,2,min(tlck.avg(ch,:)),max(tlck.avg(ch,:))]);
    title([tlck.label{ch} ' avg']);
end
filename = ['trial' num2str(cfg.trials(1)) '.png'];
print('-dpng',filename);
%%
    
%%
%-----------------Forward solution----------------------
load sourcespace;
load vol;
load elec;
%%
cfg = [];
%elec.label   % cell-array of length N with the label of each channel
%elec.elecpos % Mx3 matrix with the cartesian coordinates of each electrode
%elec.chanpos % Nx3 matrix with the cartesian coordinates of each channel
%http://fieldtrip.fcdonders.nl/faq/how_are_electrodes_magnetometers_or_gradiometers_described
%Note that there is typically a one-to-one match between electrodes and channels, 
%but in principle channels and electrodes can refer to different entities. 
%In the context of EEG, one may consider a setup containing bipolar derivations, 
%in which each 'channel' represents the voltage difference between a pair of electrodes. 
%Consequently, the number of channels N then is different from the number of electrodes M. 
%An additional field is needed in the elec-structure
%elec.tra  % NxM matrix with the weight of each electrode into each channel 
%to tell FieldTrip how to combine the electrodes into channels. This array
%can be stored as a sparse array and it also allows to set the position of the reference electrode 
%in unipolar recordings. In case elec.tra is not provided, the forward and inverse calculations 
%will be performed assuming an average reference over all electrodes.

%cfg.grad = read_elecrodes_position('BrainCapMR32Ch.txt'); % tlckFC.grad;
cfg.elec = elec; %!!! see file elecrodes_positions.m for sensor positions (we need alignment)

%cfg.elec.tra = sparse(size(cfg.elec.chanpos,1), size(cfg.elec.elecpos,1) );

%for i=1:size(cfg.elec.elecpos,1)
%    cfg.elec.tra(i,i)=1;
%end

cfg.channel = 'all';   % the used channels
cfg.sourceunits = 'mm';
cfg.grid.pos = sourcespace.pnt;              % source points
cfg.grid.inside = 1:size(sourcespace.pnt,1); % all source points are inside of the brain
cfg.vol = vol;                               % volume conduction model
leadfield = ft_prepare_leadfield(cfg);

save leadfield leadfield;

%%
%-------------------------Inverse solution-----------------------
load tlck;
load sourcespace;
load leadfield;
load vol;
load elec;
%%
cfg        = [];
cfg.method = 'mne';%mne
cfg.grid   = leadfield;
cfg.vol    = vol;
cfg.mne.prewhiten = 'yes';
cfg.mne.lambda    = 1e-5;
cfg.mne.scalesourcecov = 'yes';
%cfg.elec = read_elecrodes_position('BrainCapMR32Ch.txt'); % sensor positions
cfg.elec = elec; %see file elecrodes_positions.m for sensor positions (we need alignment)

%Error in ==> minimumnormestimate at 226
%mom = w * dat; 修改文件BrainCapMR32Ch.txt，保证channel名称和tlck一致
source  = ft_sourceanalysis(cfg,tlck);

%save -v7.3 source source;

%%
%-------------------------------Visualization------------------------
%load source;
load sourcespace;
%%
bnd.pnt = sourcespace.pnt;
bnd.tri = sourcespace.tri;
m=source.avg.pow(:,450); % plotting the result at the 450th time-point that is 
                         % 500 ms after the zero time-point
ft_plot_vol(vol, 'facecolor', 'none');alpha 0.5;
ft_plot_mesh(bnd, 'vertexcolor', m);

%%
%%------------------------TODO------------------------------
mri = ft_read_mri('mpr_brain.img');
cfg = [];
cfg.parameter = 'avg';
source2 = source;
source2.time = source.time(450:451);
source2.avg.pow = source.avg.pow(:,450:451);
interp = ft_sourceinterpolate(cfg, source2, mri);
%%
cfg = [];
%cfg.anaparameter the anatomy parameter, specifying the anatomy to be plotted
mri.m = source.avg.pow(:,450);
cfg.funparameter = 'm'; %the functional parameter, specifying the functional data to be plotted
%cfg.maskparameter the mask parameter, specifying the parameter to be used to mask the functional data
%figure;
%ft_sourceplot(cfg,mri); %only mri
%ft_sourceplot(cfg,source); %not work

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------Average over some channels and topo plot-----------
IA=25;
IB=25;
for l=IA:IB
  cfg = [];
  cfg.covariance = 'yes';
  cfg.covariancewindow = [-inf 0]; %it will calculate the covariance matrix 
                                   % on the timepoints that are  
                                   % before the zero-time point in the trials
  cfg.trials = [0];
  cfg.trials = cfg.trials + l;
  dataAvg(l) = ft_timelockanalysis(cfg, dataPRE);
end
%%
for l=IA:IB
cfg = [];
cfg.xlim = [0:0.1:2];
cfg.ylim = [-100 500];
cfg.channel = 'all';
cfg.showlabels    = 'yes';
cfg.showoutline   = 'yes';
cfg.layout = 'BrainCapMR32Ch.lay';
clf;
figure(1);
ft_multiplotER(cfg,dataAvg(l));
hold on;
figure(2);
cfg.parameter='avg';
cfg.comment = 'xlim';
cfg.commentpos = 'title';
ft_topoplotER(cfg,dataAvg(l));

pause(1)
end

%%
l=IA;
cfg = [];
cfg.elec = elec; %read_elecrodes_position('BrainCapMR32Ch.txt');
cfg.method      = 'distance';
cfg.neighbourdist = 70;
cfg.feedback    = 'yes'; % show a neighbour plot 
neighbours      = ft_prepare_neighbours(cfg, dataAvg(l)); % define neighbouring channels

%%
cfg = [];
cfg.channel     = 'all';
cfg.neighbours  = neighbours; % defined as above
cfg.latency     = [0 2];
cfg.avgovertime = 'no';
cfg.parameter   = 'individual';
cfg.method      = 'montecarlo';
cfg.statistic   = 'depsamplesT'
cfg.alpha       = 0.05;
cfg.correctm    = 'cluster';
cfg.correcttail = 'prob';
cfg.numrandomization = 1000;
cfg.minnbchan        = 2; % minimal neighbouring channels
 
Nsub = 10;
cfg.design(1,1:2*Nsub)  = [ones(1,Nsub) 2*ones(1,Nsub)];
cfg.design(2,1:2*Nsub)  = [1:Nsub 1:Nsub];
cfg.ivar                = 1; % the 1st row in cfg.design contains the independent variable
cfg.uvar                = 2; % the 2nd row in cfg.design contains the subject number
 
stat = ft_timelockstatistics(cfg, dataAvg(l))
