%查找某个区域在source.avg.pow中的索引
%方法：给定一个点和半径

%FC1: [-45.8458784523407, 20.7748469123852,-97.6360175015057]
%FC2: [-45.8458784523407,-27.5248469123852,-97.6360175015057]
%target = [-45.8458784523407, 20.7748469123852,-97.6360175015057]; %6539
%target = [-45.8458784523407,-27.5248469123852,-97.6360175015057]; %1926


%radius=15;
%motor cortex运动皮质(层)/somatosensory cortex(耳、目、口等以外的)体觉的
%target = [-23.8458784523407, -14.7748469123852,-70.6360175015057]; %left 
%target = [-27.8458784523407, 10.7748469123852,-60.6360175015057]; %right
% 
 radius=20;
%target = [-60, -60,0]; %left Temporal lobe 左颞叶
% target = [-60, 50,0]; %right Temporal lobe 右颞叶
 target = [-100, 0, -15];  %Occipital lobe 枕叶

%  radius=30;
%  target = [30, 0, -40];%Prefrontal cortex (thought elaboration)
% 
%   radius=15;
%   target = [-30, 0, -15]; %Thalamus

% % 
%  radius=8;
%  target = [-30, -9, -15]; %left Thalamus
   radius=10;
   target = [-30, 8, -15]; %right Thalamus
  
[NPnt NCol] = size(sourcespace.pnt);
pnt = sourcespace.pnt;
dis = sqrt( (target(1)-pnt(:,1)).^2 + (target(2)-pnt(:,2)).^2 + (target(3)-pnt(:,3)).^2);

% Find one point
minVal = dis(1);
minIdx = 0;
for i=1:NPnt
    if(dis(i) < minVal)
        minVal = dis(i);
        minIdx = i;
    end
end

%% Find a group of points
threshold = radius;
indices = [];
for i=1:NPnt
    if(dis(i) < threshold)
        indices(end+1) = i;
    end
end
% indicesLeft = indices;
% save indicesLeft indicesLeft
%indicesRight = indices;
%save indicesRight indicesRight

% indicesPrefrontalCortex = indices;
% save indicesPrefrontalCortex indicesPrefrontalCortex
% indicesOccipitalLobe = indices;
% save indicesOccipitalLobe indicesOccipitalLobe

% indicesLeftTemporalLobe = indices;
% save indicesLeftTemporalLobe indicesLeftTemporalLobe
% indicesRightTemporalLobe = indices;
% save indicesRightTemporalLobe indicesRightTemporalLobe

% indicesThalamus = indices;
% save indicesThalamus indicesThalamus

% 
% indicesLeftThalamus = indices;
% save indicesLeftThalamus indicesLeftThalamus
% 
 indicesRightThalamus = indices;
 save indicesRightThalamus indicesRightThalamus

%%
timeIdx=1000;
length=1000;
bnd.pnt = sourcespace.pnt;
bnd.tri = sourcespace.tri;
avg=mean(source.avg.pow(:,timeIdx-length+1:timeIdx),2); %Average over the time window with width equals 'length'
avg(indices)=100000000;
ft_plot_mesh(bnd, 'vertexcolor', avg);
hold on
plot3(target(1),target(2),target(3),'o')
axis on
grid on
% avgNormal = zeros(size(avg));
% for i=1:size(avg,1)
%     avgNormal(i) = (avg(i) - min(avg)) / ( max(avg)-min(avg) );
% end
% ft_plot_mesh(bnd.pnt, 'vertexcolor', [avgNormal zeros(size(avgNormal)) 1-avgNormal]);
view([-90 90]);

% 
% indicesRight = [
%         7040
%         7043
%         7071
%         7072
%         7073
%         7074
%         7076
%         7078
%         7149
%         7150
%         7152
%         7188
%         7219
%         7250
%         7251
%         7252
%         7253
%         7254
%         7256
%         7289
%         7290
%         7360
%         7385
%         7427
%         7428
%         7429
%         7430
%         7459
%         7482
%         7483
%         7547];

% indicesLeft = [
%         2723
%         2805
%         2806
%         2841
%         2842
%         2843
%         2844
%         2879
%         2911
%         2912
%         2914
%         2953
%         2956
%         2991
%         2994
%         3029
%         3054
%         3085
%         3086
%         3118
%         3120
%         3121
%         3150
%         3151
%         3193
%         3194
%         3225
%         3228
%         3263
%         3309];