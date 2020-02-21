%hx_data2txt_no_average_script.m

clc;
clear all;
close all;

addpath('C:\MyProject/fieldtrip_yliu/fieldtrip-20150911');
ft_defaults

%%
load dataPRE;
trial = dataPRE.trial;

% write baseine trial
curr = trial{1};
dlmwrite('baseline.txt',curr,'delimiter','\t');

% write right hand, warm water trials
counter = 1;
for i = 2 : 4 : length(trial)
    curr = trial{i};
    filename = ['right_warm_trial_',num2str(counter),'.txt'];
    dlmwrite(filename,curr,'delimiter','\t');
    counter = counter + 1;
end


% write right hand, cold water trials
counter = 1;
for i = 3 : 4 : length(trial)
    curr = trial{i};
    filename = ['right_cold_trial_',num2str(counter),'.txt'];
    dlmwrite(filename,curr,'delimiter','\t');
    counter = counter + 1;
end

% write left hand, warm water trials
counter = 1;
for i = 4 : 4 : length(trial)
    curr = trial{i};
    filename = ['left_warm_trial_',num2str(counter),'.txt'];
    dlmwrite(filename,curr,'delimiter','\t');
    counter = counter + 1;
end

% write left hand, cold water trials
counter = 1;
for i = 5 : 4 : length(trial)
    curr = trial{i};
    filename = ['left_cold_trial_',num2str(counter),'.txt'];
    dlmwrite(filename,curr,'delimiter','\t');
    counter = counter + 1;
end
