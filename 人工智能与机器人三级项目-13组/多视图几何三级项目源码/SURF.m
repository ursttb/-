%% 清楚工作空间
clc;

%% 读取参考图片 
WZImage = imread('2.jpg');
WZImage = rgb2gray(WZImage);
figure;
imshow(WZImage);
title('Image of a Wangzai');

%% 读取要处理的图片
WZCImageColor = imread('3.jpg');
WZCImage = rgb2gray(WZCImageColor);
figure;
imshow(WZCImage);
title('Image of a WangzaiCan');

%% 提取特征点
tic;
WZPoints = detectSURFFeatures(WZImage);
WZCPoints = detectSURFFeatures(WZCImage);
t_sys = toc;

%% Visualize the strongest feature points found in the reference image.
figure;
imshow(WZImage);
title('100 Strongest Feature Points from WZ Image');
hold on;
plot(selectStrongest(WZPoints, 100));

%% Visualize the strongest feature points found in the target image.
figure;
imshow(WZCImage);
title('300 Strongest Feature Points from WZC Image');
hold on;
plot(selectStrongest(WZCPoints, 300));

%% 提取特征描述
[WZFeatures, WZPoints] = extractFeatures(WZImage, WZPoints);
[WZCFeatures, WZCPoints] = extractFeatures(WZCImage, WZCPoints);

%% 找到匹配点
Pairs = matchFeatures(WZFeatures, WZCFeatures);

%% 显示匹配效果
matchedWZPoints = WZPoints(Pairs(:, 1), :);
matchedWZCPoints = WZCPoints(Pairs(:, 2), :);
figure;
showMatchedFeatures(WZImage, WZCImage, matchedWZPoints, ...
    matchedWZCPoints, 'montage');
title('Putatively Matched Points (Including Outliers)');

%% 通过匹配找到特定的物体
[tform, inlierIdx] = ...
    estgeotform2d(matchedWZPoints, matchedWZCPoints, 'affine');%https://www.bilibili.com/video/BV1n441147kH/?vd_source=e2d95ae1a4a936f9c286d0e588576c09
inlierWZPoints = matchedWZPoints(inlierIdx,:);
inlierWZCPoints = matchedWZCPoints(inlierIdx,:);
%tform是图像1内点转化为图像2内点的affine变换矩阵
%% 显示匹配效果
figure;
showMatchedFeatures(WZImage, WZCImage, inlierWZPoints, ...
    inlierWZCPoints, 'montage');
title('Matched Points (Inliers Only)');

%Get the bounding polygon of the reference image.
WZPolygon = [1, 1;...                           % top-left
        size(WZImage, 2), 1;...                 % top-right
        size(WZImage, 2), size(WZImage, 1);... % bottom-right
        1, size(WZImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
newWZPolygon = transformPointsForward(tform, WZPolygon);
%将参考图4个点的位置通过tform矩阵进行变换，找出再检测图中参考图的位置。

%% 显示被检测到的物体
figure;
imshow(WZCImageColor);
hold on
line(newWZPolygon(:, 1), newWZPolygon(:, 2), Color = "blue");
title(['SURFDetected WZ耗时(s)：',num2str(t_sys)])



