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
view(3);
robot.teach();