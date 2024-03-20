%%画圆
L1 = Link('offset',0,'d', 0.16124+0.19026, 'a', 0.02970, 'alpha', pi/2,'qlim',[-150,150]/180*pi);
L2 = Link('offset',pi/2,'d', 0, 'a', 0.26043, 'alpha', 0,'qlim',[-120,120]/180*pi);
L3 = Link('d', 0, 'a', 0.04, 'alpha', pi/2,'offset',0,'qlim',[-100,100]/180*pi);
L4 = Link('d', 0.19451+0.07276, 'a', 0, 'alpha', -pi/2,'offset',0,'qlim',[-150,150]/180*pi);
L5 = Link('offset',-pi/2,'d', 0, 'a', 0, 'alpha', pi/2,'qlim',[-100,100]/180*pi);
L6 = Link('d', 0.14, 'a', 0, 'alpha', 0,'offset',0,'qlim',[-150,150]/180*pi);
n=3000;
bot = SerialLink([L1 L2 L5 L6], 'name', 'my robot');
view(3);
bot.teach();
hold on;
%定义圆
N = (0:0.5:100)'; 
center = [0.28 0 0.4];
radius = 0.12;
theta = ( N/N(end) )*2*pi;
%计算圆弧各点坐标
points = (center + radius*[cos(theta) sin(theta) zeros(size(theta))])' ;
plot3(points(1,:),points(2,:),points(3,:)-0.04,'r');
grid on;
hold on;
view(3);
%计算圆弧各点坐标对应变换算子
T = transl(points');
for i=1:201
   T(:,:,i) = T(:,:,i)*rpy2tr(-180,0,0);
end
%进行逆运动学求解
q1 = bot.ikine(T,'mask',[1 1 1 1 1 1]);
bot.plot(q1,'movie','trail.gif');%保存
robot.plot(qq); 