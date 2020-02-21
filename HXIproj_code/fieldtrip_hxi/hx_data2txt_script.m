%hx_data2txt_script.m

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

% write right hand, warm water, averaged trial
counter = 0;
for i = 2 : 4 : length(trial)
    if counter == 0
        curr = trial{i};
    else
        curr = curr + trial{i};
    end
    counter = counter + 1;
end
dlmwrite('right_warm_average.txt',curr/counter,'delimiter','\t');

% write right hand, cold water, averaged trial
counter = 0;
for i = 3 : 4 : length(trial)
    if counter == 0
        curr = trial{i};
    else
        curr = curr + trial{i};
    end
    counter = counter + 1;
end
dlmwrite('right_cold_average.txt',curr/counter,'delimiter','\t');

% write left hand, warm water, averaged trial
counter = 0;
for i = 4 : 4 : length(trial)
    if counter == 0
        curr = trial{i};
    else
        curr = curr + trial{i};
    end
    counter = counter + 1;
end
dlmwrite('left_warm_average.txt',curr/counter,'delimiter','\t');

% write left hand, cold water, averaged trial
counter = 0;
for i = 5 : 4 : length(trial)
    if counter == 0
        curr = trial{i};
    else
        curr = curr + trial{i};
    end
    counter = counter + 1;
end
dlmwrite('left_cold_average.txt',curr/counter,'delimiter','\t');
