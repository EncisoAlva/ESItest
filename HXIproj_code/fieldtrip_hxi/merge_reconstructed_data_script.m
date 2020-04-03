% merge_reconstructed_data_script.m


clc;
clear all;
close all;

%%
inputDir = '../data/input/Tmp';
%inputDir = '.';
merged_data = [];

for i = -1:2:57
    i
    currFilename = [inputDir, filesep, 'recon_data_',num2str(i),'.mat'];
    load(currFilename); % default variable name is recon_data
    merged_data = [merged_data, recon_data];
end

disp('Writing on the disk ...');
save merged_data merged_data;
disp('done!');

