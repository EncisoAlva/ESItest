%clc;
%clear all;
%close all;

%addpath('C:/MyProject/fieldtrip-20130901');
addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

addpath('C:\MyProject\data\output\Peng\Sub2_RC');
load ersp_lac;
ersp_lac = ersp;
load ersp_lpf;
ersp_lpf = ersp;
load ersp_lss;
ersp_lss = ersp;
load ersp_lt;
ersp_lt = ersp;
load ersp_rac;
ersp_rac = ersp;
load ersp_rpf;
ersp_rpf = ersp;
load ersp_rss;
ersp_rss = ersp;
load ersp_rt;
ersp_rt = ersp;

load times;
load frequencies;

%%
for i = 1 : length(frequencies)
    figure;hold on;
    titleID = [num2str(frequencies(i)), ' Hz'];
    plot(times, ersp_lac(i,:), ...
         times, ersp_lpf(i,:), ...
         times, ersp_lss(i,:), ...
         times, ersp_lt(i,:));
    title(titleID);
    legend('lac','lpf','lss','lt');
end

%%
% figure;
% for i = 1 : length(frequencies)
%     hold on;
%     titleID = [num2str(frequencies(i)), ' Hz'];
%     plot(times, ersp_lac(i,:), ...
%          times, ersp_rac(i,:));
%     title(titleID);
% end

