% bdf2mat_script.m

%%
% clear all;
% close all;
% clc;

% addpath(genpath(pwd));
% ft_defaults;
%addpath('../fieldtrip-20130901');
%addpath('../fieldtrip-20150911');
addpath('C:/MyProject/fieldtrip-20151222');
ft_defaults

%% data reading
pathName = 'C:\MyProject\data\input\Liu_Ola\';
fileName = 'hemond-resting_clean.bdf';
fullName = [pathName, fileName];

hdr = ft_read_header(fullName);
dat = ft_read_data(fullName); % nChan x nSamples
hemond_resting = dat;
save hemond_resting hemond_resting;