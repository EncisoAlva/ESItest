% down_sample_raw_data_script.m

clc;
%clear all;
close all;

%addpath('C:/MyProject/fieldtrip-20130901');
addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

newFreq = 512;

%%
inputDir = '../data/input';
outputDir = '../data/output';
dirName = 'Liu_Ola';
pathName = [inputDir, filesep, dirName];
prefix = 'amarnath_resting'; %'waterpain1';%'coldpressor2'
suffix = '.bdf';
fileName = [prefix, suffix];
fullName = [pathName, filesep, fileName];
    
hdr   = ft_read_header(fullName);
event = ft_read_event(fullName);
dat = ft_read_data(fullName); % nChan x nSamples

% down sampling 512 Hz
freq = hdr.Fs;
interval = freq / 512;
dat1 = dat(:,1:interval:end);


