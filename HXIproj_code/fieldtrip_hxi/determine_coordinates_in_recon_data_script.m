% determine_coordinates_in_recon_data_script.m

clc;
clear all;
close all;

%addpath('C:/MyProject/fieldtrip-20130901');
addpath('C:/MyProject/fieldtrip-20150911');
ft_defaults

load sourcespace_template;

pnt = sourcespace.pnt;
x=pnt(:,1);
y=pnt(:,2);
z=pnt(:,3);

%% left middle brain
ind1 = x>=0.005 & x<=0.038;
ind2 = y>=0.012 & y<=0.035;
ind3 = z>=0.08 & z<=0.12;

ind4 = ind1 & ind2 & ind3;
ind = find(ind4==1);

pattern3 = zeros(8196,1);
pattern3(ind) = 1;

figure;
ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
view(0,90);%top view

ind_left_middle_brain = ind;
save ind_left_middle_brain ind_left_middle_brain;

%% right middle brain
ind1 = x>=0.005 & x<=0.038;
ind2 = y>=-0.035 & y<=-0.012;
ind3 = z>=0.08 & z<=0.12;

ind4 = ind1 & ind2 & ind3;
ind = find(ind4==1);

pattern3 = zeros(8196,1);
pattern3(ind) = 1;

figure;
ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
view(0,90);%top view

ind_right_middle_brain = ind;
save ind_right_middle_brain ind_right_middle_brain;

%% left thalamus
center = [0.025 0.017 0.019];
radius = 0.015;
ind = hx_find_indices_in_sphere(pnt,center,radius);

pattern3 = zeros(8196,1);
pattern3(ind) = 1;

figure;
ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
view(0,90);%top view

ind_left_thalamus = ind;
save ind_left_thalamus ind_left_thalamus;

%% right thalamus
center = [0.025 -0.017 0.019];
radius = 0.015;
ind = hx_find_indices_in_sphere(pnt,center,radius);

pattern3 = zeros(8196,1);
pattern3(ind) = 1;

figure;
ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
view(0,90);%top view

ind_right_thalamus = ind;
save ind_right_thalamus ind_right_thalamus;

%% left anterior cingulate cotex
% center = [0.07 0.016 0.02];
% radius = 0.015;
% ind = hx_find_indices_in_sphere(pnt,center,radius);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = 1;
% 
% figure;
% ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
% view(0,90);%top view
% 
% ind_left_cingulate = ind;
% save ind_left_cingulate ind_left_cingulate;

%% right anterior cingulate cotex
% center = [0.07 -0.016 0.02];
% radius = 0.015;
% ind = hx_find_indices_in_sphere(pnt,center,radius);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = 1;
% 
% figure;
% ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
% view(0,90);%top view
% 
% ind_right_cingulate = ind;
% save ind_right_cingulate ind_right_cingulate;

%% left somatosensory cotex
% center = [0.02 0.017 0.08];
% radius = 0.015;
% ind = hx_find_indices_in_sphere(pnt,center,radius);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = 1;
% 
% figure;
% ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
% view(0,90);%top view
% 
% ind_left_somato = ind;
% save ind_left_somato ind_left_somato;

%% right somatosensory cotex
% center = [0.02 -0.017 0.08];
% radius = 0.015;
% ind = hx_find_indices_in_sphere(pnt,center,radius);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = 1;
% 
% figure;
% ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
% view(0,90);%top view
% 
% ind_right_somato = ind;
% save ind_right_somato ind_right_somato;

%% left prefrontal lobe
% center = [0.08 0.02 0.052];
% radius = 0.015;
% ind = hx_find_indices_in_sphere(pnt,center,radius);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = 1;
% 
% figure;
% ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
% view(0,90);%top view
% 
% ind_left_prefrontal = ind;
% save ind_left_prefrontal ind_left_prefrontal;

%% right prefrontal lobe
% center = [0.08 -0.02 0.052];
% radius = 0.015;
% ind = hx_find_indices_in_sphere(pnt,center,radius);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = 1;
% 
% figure;
% ft_plot_mesh(sourcespace, 'vertexcolor', pattern3);
% view(0,90);%top view
% 
% ind_right_prefrontal = ind;
% save ind_right_prefrontal ind_right_prefrontal;

%% not used
% load vol_template;
% 
% vol_data = zeros(size(vol.bnd(3).pnt,1),1);
% 
% % plot vol
% figure;
% ft_plot_mesh(vol.bnd(3), 'vertexcolor', vol_data);
% view(0,90);%top view
% 
% vol_pnt = vol.bnd(3).pnt;
% 
% x=vol_pnt(:,1);
% y=vol_pnt(:,2);
% z=vol_pnt(:,3);
% 
% %% right prefrontal cortex
% ind1 = x>=-30 & x<=-26;
% ind2 = y>=50 & y<=54;
% ind3 = z>=17 & z<=21;
% 
% ind4 = ind1 & ind2 & ind3;
% ind = find(ind4==1);
% 
% pattern3 = zeros(8196,1);
% pattern3(ind) = 1;


