% This script asks for a particular coordinate, then plots the activity
% history at that coordinate --approximated to the nearest point on the
% grid for the inverse solution.

%% PARAMETER
%
% units here are mm, as in the plot
xx =  91;
yy =  65;
zz =  81;

%% IDENTIFICATION OF THE POINT
%
% units in sourceFC.pos are m
idx = dsearchn( sourceFC.pos, [xx yy zz]/1000 );
sourceFC.pos(idx,:)*1000;

% % verify that the best point is found
% ft_plot_headshape(sourcespace, 'unit', 'cm')
% hold on
% plot(sourceFC.pos(idx,:),'col','r')
% hold off

%% ACTIVITY HISTORY AT GIVEN POINT
figure()
plot( sourceFC.time, sourceFC.avg.pow(idx,:) )
title(['Activity history at [',num2str([xx yy zz]),']'])
xlabel('Time (s)')
ylabel('Activity ("unit")')
%xlim([0 1])