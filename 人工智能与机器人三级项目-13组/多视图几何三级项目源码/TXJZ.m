
img = rgb2gray(imread('cpuls.jpg'));
width = size(img,2);
height = size(img,1);
figure;imshow(img)
moving_points = ginput(4);
hold on ; plot(moving_points(:,1),moving_points(:,2),'ro');
fixed_points = [0,0;
    100,0;
    0,200;
    100,200];

tfom = fitgeotrans(moving_points,fixed_points,'projective');
%X = moving_points(:,1);
%Y = moving_points(:,2);
%[x,y] = transformPointsForward(tfom,X(:),Y(:));
%figure;plot(x,y,'ro');title('验证坐标点对齐')
%grid on
tic;
dst_img = imwarp(img,tfom);
t_sys = toc;
figure;imshow(dst_img);title(['图像仿射变换后（系统函数），耗时(s)：',num2str(t_sys)])
