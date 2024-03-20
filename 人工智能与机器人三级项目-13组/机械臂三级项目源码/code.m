clc; % 清空命令窗口
clear; % 清空工作空间变量
 
%% 机械臂建模
% 定义各个连杆以及关节类型，默认为转动关节
%          theta      d       a      alpha
L1=Link([     0       0        0      pi/2], 'standard'); % 第一个连杆 DH 参数：关节角度 theta, 运动方向 d, 连杆长度 a, 连杆扭转角 alpha
L2=Link([     0       0      0.105     0], 'standard'); % 第二个连杆 DH 参数
L3=Link([     0       0      0.09      0], 'standard'); % 第三个连杆 DH 参数
L4=Link([     0       0      0.04      0], 'standard'); % 第四个连杆 DH 参数
b=isrevolute(L1); % 检测关节是否为转动关节1/0
robot=SerialLink([L1,L2,L3,L4],'name','Irvingao Arm'); % 将四个连杆组成机械臂
robot.name='kunkun’s Robotic Arm';
robot.display();
 
%% 轨迹规划
% 初始值及目标值
init_ang=[0 0 0 0]; % 初始关节角度
targ_ang=[0, -pi/6, -pi/5, pi/6]; % 目标（结束）关节角度
step=200; % 轨迹离散点数
 
[q,qd,qdd]=jtraj(init_ang,targ_ang,step); % 关节空间规划轨迹（根据初始和结束关节角度），得到机器人末端运动的[位置，速度，加速度]
T0=robot.fkine(init_ang); % 正运动学解算，得到初始末端变换矩阵
Tf=robot.fkine(targ_ang); % 正运动学解算，得到目标末端变换矩阵
 
subplot(2,4,3); i=1:4; plot(q(:,i)); title("位置"); grid on; % 绘制关节角度随时间的变化
subplot(2,4,4); i=1:4; plot(qd(:,i)); title("速度"); grid on; % 绘制关节角速度随时间的变化
subplot(2,4,7); i=1:4; plot(qdd(:,i)); title("加速度"); grid on; % 绘制关节角加速度随时间的变化
 %提取轨迹
Tc=ctraj(T0,Tf,step); % 笛卡尔空间规划轨迹，得到机器人末端运动位置和姿态的变换矩阵（轨迹信息）
Tjtraj=transl(Tc); % 提取变换矩阵中的平移部分
subplot(2,4,8); %大窗口内同时显示多个图
plot2(Tjtraj, 'r'); % 在末端空间上绘制机器人的笛卡尔轨迹,r红色
title('p1到p2直线轨迹'); 
grid on;%打开子图的网格显示，以提高图形的可读性
 
subplot(2,4,[1,2,5,6]);
plot3(Tjtraj(:,1),Tjtraj(:,2),Tjtraj(:,3),"b"); grid on; % 在3D空间上绘制机器人的笛卡尔轨迹
hold on;
view(3); % 设置视图方向,解决robot.teach()和plot的索引超出报错
qq=robot.ikine(Tc, 'q0',[0 0 0 0], 'mask',[1 1 1 1 0 0]); % 逆解算，得到关节角度
robot.plot(qq); % 绘制机器人在轨迹上的位置（机械臂移动可视化）

