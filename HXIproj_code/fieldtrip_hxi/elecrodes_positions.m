%%
% Copyright (C) 2013 Yueming Liu, University of Texas at Arlington
% http://www.fieldtriptoolbox.org/tutorial/headmodel_eeg

clc;
clear all;
close all;

addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

%%
%elec = ft_read_sens('standard_1020.elc');  %standard_1020.elc GSN-HydroCel-32.sfp
%elec = read_elecrodes_position('BrainCapMR32Ch.txt');
%elec = read_elecrodes_position('easycap-M1_hxi64_haley.txt')
elec = read_elecrodes_position('biosemi_hxi64.txt')
%elec=ft_read_sens('easycap-M1.txt');
%elec=ft_read_sens('easycapM1.mat');

%% read easycapM1.mat layout
% cfg = [];
% cfg.layout = 'easycapM1.mat';
% layout = ft_prepare_layout(cfg);
% 
% figure;
% ft_plot_lay(layout);
% title(cfg.layout);

%% load volume conduction model
%load C:\MyProject\data\input\Peiying\sub1-2013-12-19\sub1_artifact_correction\vol;
% ft_plot_vol(vol, 'facecolor', 'none');
%load C:\MyProject\fieldtrip_hxi\vol;
% load vol_20150906;
load vol_template;
ft_plot_vol(vol, 'facecolor', 'none');

%%
figure;
% head surface (scalp)
ft_plot_mesh(vol.bnd(1), 'edgecolor',[0.4,0.4,0.7],'edgealpha',0.3,'facealpha',0.2,'facecolor',[0.6 0.6 0.8]); 
hold on;

% electrodes
%ft_plot_sens(elec,'style', 'sk');  
ft_plot_sens(elec,'label','label');    
%view([90 -90]);
view([4 28]);

%% Automatic alignment
% mri = ft_read_mri('C:/MyProject/data/input/Subject01/Subject01.mri');
% 
% disp(mri.hdr.fiducial.mri)

%%
% % we get these positions in the ctf coordinate system using 
% % the transformation matrix of the mri and the warp_apply function.
% nas=mri.hdr.fiducial.mri.nas;
% lpa=mri.hdr.fiducial.mri.lpa;
% rpa=mri.hdr.fiducial.mri.rpa;
%  
% transm=mri.transform;
%  
% nas=warp_apply(transm,nas, 'homogenous');
% lpa=warp_apply(transm,lpa, 'homogenous');
% rpa=warp_apply(transm,rpa, 'homogenous');

%% 
% % we align the position of the fiducials in the electrode structure 
% % (defined with labels 'Nz', 'LPA', 'RPA') to their ctf-coordinates that 
% % we acquired from the anatomical mri (nas, lpa, rpa).
% % create a structure similar to a template set of electrodes
% fid.chanpos       = [nas; lpa; rpa];       % ctf-coordinates of fiducials
% fid.label         = {'Nz','LPA','RPA'};    % same labels as in elec 
% fid.unit          = 'mm';                  % same units as mri
% 
% % I got fiducial positions from standard_1020.lec file, and try to attach
% % these 3 rows to elec.
% fid1020 = [0.0083 86.8110 -39.9830;
%            85.7939 -20.0093 -48.0310;
%            -86.0761 -19.9897 -47.9860];
% elec.label=[elec.label;{'Nz'};{'LPA'};{'RPA'}];
% newpos = [elec.chanpos;fid1020];
% elec.chanpos=newpos;
% elec.elecpos=newpos;
% elec.pnt=newpos;
% 
% % alignment
% cfg               = [];
% cfg.method        = 'fiducial';            
% cfg.template      = fid;                   % see above
% cfg.elec          = elec;
% cfg.fiducial      = {'Nz', 'LPA', 'RPA'};  % labels of fiducials in fid and in elec
% elec_aligned      = ft_electroderealign(cfg);
% 
% save elec_aligned elec_aligned;

%%
% % We can check the alignment by plotting together the scalp surface with the electrodes.
% figure;
% ft_plot_sens(elec_aligned,'label','label');
% hold on;
% ft_plot_mesh(vol.bnd(1),'facealpha', 0.85, 'edgecolor', 'none', 'facecolor', [0.65 0.65 0.65]); %scalp

%%
%Align electrodes interactively
cfg           = [];
cfg.method    = 'interactive';
cfg.elec      = elec;
cfg.headshape = vol.bnd(1);
elec_old = elec;
elec  = ft_electroderealign(cfg);
cfg.elec = elec;
save elec elec;

% keep rotating around z-axis until POz and Oz are in the central vertical
% line on the back-head. Then, translate upward along z-axis until
% satisfactory.