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
WZPoints = detectORBFeatures(WZImage);
WZCPoints = detectORBFeatures(WZCImage);
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
    estgeotform2d(matchedWZPoints, matchedWZCPoints, 'affine');
inlierWZPoints = matchedWZPoints(inlierIdx,:);
inlierWZCPoints = matchedWZCPoints(inlierIdx,:);
%% 显示匹配效果
figure;
showMatchedFeatures(WZImage, WZCImage, inlierWZPoints, ...
    inlierWZCPoints, 'montage');
title('Matched Points (Inliers Only)');

WZPolygon = [1, 1;...                           % top-left
        size(WZImage, 2), 1;...                 % top-right
        size(WZImage, 2), size(WZImage, 1);... % bottom-right
        1, size(WZImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
newWZPolygon = transformPointsForward(tform, WZPolygon);
%t_sys = toc;

%% 显示被检测到的物体
figure;
imshow(WZCImageColor);
hold on
line(newWZPolygon(:, 1), newWZPolygon(:, 2), Color = 'b');
title(['OBRDetected WZ耗时(s)：',num2str(t_sys)])

