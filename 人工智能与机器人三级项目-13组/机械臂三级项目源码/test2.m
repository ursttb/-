clear ; clc; close all;
% 机器人各连杆DH参数
d1 = 0;
d2 = 86;
d3 = -92;
% 由于关节4为移动关节，故d4为变量，theta4为常量
theta4 = 0;

a1 = 400;
a2 = 250;
a3 = 0;
a4 = 0;

alpha1 = 0 / 180 * pi;
alpha2 = 0 / 180 * pi;
alpha3 = 180 / 180 * pi;
alpha4 = 0 / 180 * pi;
% 定义各个连杆，默认为转动关节
%           theta      d        a        alpha 
L(1)=Link([  0         d1      a1      alpha1]); L(1).qlim=[-pi,pi];
L(2)=Link([  0         d2      a2      alpha2]); L(2).qlim=[-pi,pi]; L(2).offset=pi/2;
L(3)=Link([  0         d3      a3      alpha3]); L(3).qlim=[-pi,pi];
% 移动关节需要特别指定关节类型--jointtype
L(4)=Link([theta4       0      a4      alpha4]); L(4).qlim=[0,180]; L(4).jointtype='P';
% 把上述连杆“串起来”
Scara=SerialLink(L,'name','Scara');
% 定义机器人基坐标和工具坐标的变换
Scara.base = transl(0 ,0 ,305);
Scara.tool = transl(0 ,0 ,100);
view(3);
Scara.teach();


