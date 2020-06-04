%generate_leadfield_script.m

clear all;
close all;
clc;

addpath('../fieldtrip-20130901');
ft_defaults;

load sourcespace_template;
load vol_template;
load elec_biosemi;%elec_template; 

%% Forward solution
cfg = [];
cfg.grad = elec;                      % sensor positions
cfg.channel = {'all'};   % the used channels
cfg.grid.pos = sourcespace.pnt;              % source points
cfg.grid.inside = 1:size(sourcespace.pnt,1); % all source points are inside of the brain
cfg.vol = vol;                               % volume conduction model
leadfield = ft_prepare_leadfield(cfg);

save leadfield leadfield;