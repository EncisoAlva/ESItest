%hx_data2txt_no_average_t_script.m

clc;
clear all;
close all;

addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

%%
load dataPRE;
trial = dataPRE.trial;

start = 0;
% write baseine trial
if start >0
    curr = trial{start};
    dlmwrite('baseline.txt',curr','delimiter','\t');
end

% write right hand, warm water trials
counter = 1;
for i = start+1 : 4 : length(trial)
    curr = trial{i};
    filename = ['right_warm_trial_',num2str(counter),'.txt'];
    dlmwrite(filename,curr','delimiter','\t');
    counter = counter + 1;
end


% write right hand, cold water trials
counter = 1;
for i = start+2 : 4 : length(trial)
    curr = trial{i};
    filename = ['right_cold_trial_',num2str(counter),'.txt'];
    dlmwrite(filename,curr','delimiter','\t');
    counter = counter + 1;
end

% write left hand, warm water trials
counter = 1;
for i = start+3 : 4 : length(trial)
    curr = trial{i};
    filename = ['left_warm_trial_',num2str(counter),'.txt'];
    dlmwrite(filename,curr','delimiter','\t');
    counter = counter + 1;
end

% write left hand, cold water trials
counter = 1;
for i = start+4 : 4 : length(trial)
    curr = trial{i};
    filename = ['left_cold_trial_',num2str(counter),'.txt'];
    dlmwrite(filename,curr','delimiter','\t');
    counter = counter + 1;
end
