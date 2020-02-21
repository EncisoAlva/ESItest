% recon2channel_script.m

load recon_mat;
% load ind_left_middle_brain;
% load ind_right_middle_brain;
% ind_left = ind_left_middle_brain;
% ind_right = ind_right_middle_brain;

%% prefrontal
% load ind_left_prefrontal;
% load ind_right_prefrontal;
% ind_left = ind_left_prefrontal;
% ind_right = ind_right_prefrontal;
% 
% channel_left = 34; %AF3
% channel_right = 35; %AF4
% 
% left = recon_mat(ind_left,:);
% right = recon_mat(ind_right,:);
% 
% channel_data = zeros(64,size(recon_mat,2));
% channel_data(channel_left,:) = mean(left,1);
% channel_data(channel_right,:) = mean(right,1);
% 
% save channel_data channel_data;

%% anterior cingulate cortex
% load ind_left_cingulate;
% load ind_right_cingulate;
% ind_left = ind_left_cingulate;
% ind_right = ind_right_cingulate;
% 
% channel_left = 3; %F7
% channel_right = 7; %F8
% 
% left = recon_mat(ind_left,:);
% right = recon_mat(ind_right,:);
% 
% channel_data = zeros(64,size(recon_mat,2));
% channel_data(channel_left,:) = mean(left,1);
% channel_data(channel_right,:) = mean(right,1);
% 
% save channel_data channel_data;

%% somatosensory cortex
% load ind_left_somato;
% load ind_right_somato;
% ind_left = ind_left_somato;
% ind_right = ind_right_somato;
% 
% channel_left = 13; %C3
% channel_right = 15; %C4
% 
% left = recon_mat(ind_left,:);
% right = recon_mat(ind_right,:);
% 
% channel_data = zeros(64,size(recon_mat,2));
% channel_data(channel_left,:) = mean(left,1);
% channel_data(channel_right,:) = mean(right,1);
% 
% save channel_data channel_data;

%% thalamus
load ind_left_thalamus;
load ind_right_thalamus;
ind_left = ind_left_thalamus;
ind_right = ind_right_thalamus;

channel_left = 52; %CP3
channel_right = 54; %CP4

left = recon_mat(ind_left,:);
right = recon_mat(ind_right,:);

channel_data = zeros(64,size(recon_mat,2));
channel_data(channel_left,:) = mean(left,1);
channel_data(channel_right,:) = mean(right,1);

save channel_data channel_data;

