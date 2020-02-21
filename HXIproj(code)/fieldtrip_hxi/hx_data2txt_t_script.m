%hx_data2txt_t_script.m

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

% write right hand, warm water, averaged trial
counter = 0;
for i = start+1 : 4 : length(trial)
    if counter == 0
        curr = trial{i};
    else
        curr = curr + trial{i};
    end
    counter = counter + 1;
end
dlmwrite('right_warm_average.txt',curr'/counter,'delimiter','\t');

% write right hand, cold water, averaged trial
counter = 0;
for i = start+2 : 4 : length(trial)
    if counter == 0
        curr = trial{i};
    else
        curr = curr + trial{i};
    end
    counter = counter + 1;
end
dlmwrite('right_cold_average.txt',curr'/counter,'delimiter','\t');

% write left hand, warm water, averaged trial
counter = 0;
for i = start+3 : 4 : length(trial)
    if counter == 0
        curr = trial{i};
    else
        curr = curr + trial{i};
    end
    counter = counter + 1;
end
dlmwrite('left_warm_average.txt',curr'/counter,'delimiter','\t');

% write left hand, cold water, averaged trial
counter = 0;
for i = start+4 : 4 : length(trial)
    if counter == 0
        curr = trial{i};
    else
        curr = curr + trial{i};
    end
    counter = counter + 1;
end
dlmwrite('left_cold_average.txt',curr'/counter,'delimiter','\t');
