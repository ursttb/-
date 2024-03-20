%% MATLAB素质三连
clear all
clc
%% 实验一 基于MATLAB的关节型六轴机械臂仿真
%% 参数定义
%% 机械臂为六自由度机械臂
%角度转换
angle=pi/180;  %度
 
%D-H参数表
theta1 = 0;   D1 = 0.4;   A1 = 0.025; alpha1 = pi/2; offset1 = 0;
theta2 = pi/2;D2 = 0;     A2 = 0.56;  alpha2 = 0;    offset2 = 0;
theta3 = 0;   D3 = 0;     A3 = 0.035; alpha3 = pi/2; offset3 = 0;
theta4 = 0;   D4 = 0.515; A4 = 0;     alpha4 = pi/2; offset4 = 0;
theta5 = pi;  D5 = 0;     A5 = 0;     alpha5 = pi/2; offset5 = 0;
theta6 = 0;   D6 = 0.08;  A6 = 0;     alpha6 = 0;    offset6 = 0;

%% DH法建立模型,关节转角，关节距离，连杆长度，连杆转角，关节类型（0转动，1移动）

L(1) = Link([theta1, D1, A1, alpha1, offset1], 'standard')
L(2) = Link([theta2, D2, A2, alpha2, offset2], 'standard')
L(3) = Link([theta3, D3, A3, alpha3, offset3], 'standard')
L(4) = Link([theta4, D4, A4, alpha4, offset4], 'standard')
L(5) = Link([theta5, D5, A5, alpha5, offset5], 'standard')
L(6) = Link([theta6, D6, A6, alpha6, offset6], 'standard')

% 定义关节范围
L(1).qlim =[-180*angle, 180*angle];
L(2).qlim =[-180*angle, 180*angle];
L(3).qlim =[-180*angle, 180*angle];
L(4).qlim =[-180*angle, 180*angle];
L(5).qlim =[-180*angle, 180*angle];
L(6).qlim =[-180*angle, 180*angle];


%% 2.2求解运动学正解
robot2 = SerialLink(L,'name','sixsixsix');
theta2 = [0.1,0,0,0,0,0];   			%实验二指定的关节角
p=robot2.fkine(theta2)       			%fkine正解函数，根据关节角theta，求解出末端位姿p
q=ikine(robot2,p)            			%ikine逆解函数，根据末端位姿p，求解出关节角q

%% 2.3 jtraj 已知初始和终止的关节角度，利用五次多项式来规划轨迹
% T1=transl(0.5,0,0);					%根据给定起始点，得到起始点位姿
% T2=transl(0,0.5,0);					%根据给定终止点，得到终止点位姿
T1=transl(0.5,0,0);						%根据给定起始点，得到起始点位姿
T2=transl(0,0.5,0);						%根据给定终止点，得到终止点位姿
init_ang=robot2.ikine(T1);				%根据起始点位姿，得到起始点关节角
targ_ang=robot2.ikine(T2);				%根据终止点位姿，得到终止点关节角
step = 20;
f = 3

%轨迹规划方法
figure(f)
[q ,qd, qdd]=jtraj(init_ang,targ_ang,step);
 %五次多项式轨迹，得到关节角度，角速度，角加速度，50为采样点个数
grid on
T=robot2.fkine(q);						%根据插值，得到末端执行器位姿
nT=T.T;
plot3(squeeze(nT(1,4,:)),squeeze(nT(2,4,:)),squeeze(nT(3,4,:)));%输出末端轨迹
title('输出末端轨迹');
robot2.plot(q);							%动画演示 




