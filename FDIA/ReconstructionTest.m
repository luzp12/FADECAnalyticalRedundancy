clear;
close all;
%加载数据
load Data01.mat;
load DataJudgement.mat;
load RXY.mat;
load ab.mat

%总变量数,根据n载入数据
n=8;
nx=8;
ab(:,nx)
%定义观测的到参数矩阵
M=A;
%tfault个点之后，数据丢失
tfault=10000;
M(tfault:length(M),nx)=0;
P=10^6.*eye(7,7);
%%开始仿真
for k=1:length(M)
  %当故障未发生时，利用卡尔曼滤波更新模型
  if k <tfault&&abs((M(k,nx)-[M(k,1:6) 1]*ab(:,nx)))>0.01*DataJudgement(2,nx)
    %====计算模型参数====
    %计算 A: x=Ax,7*7
    Aab=eye(7,7);
    %计算H: z=Hx+e,1*7
    H=[M(k,1:6) 1];
    %====定义噪声参数====
    Q=0*eye(7,7);
    R=0.001;
    %====估计协方差矩阵Pguess:7*7====
    Pguess=Aab*P*Aab'+Q;
    %====计算增益K:====
    K=Pguess*H'/(H*Pguess*H'+R);
    %====更新协方差矩阵====
    P=(eye(7)-K*H)*Pguess;     
    %====状态更新====
    ab(:,nx)=ab(:,nx)+K*(M(k,nx)-H*ab(:,nx));
    %当故障发生时，利用当前模型产生重构信号
    
  end
  M(k,nx)=[M(k,1:6) 1]*ab(:,nx);
end

figure(1)
time=1:length(M);

plot(time,M(:,nx),'-b',time,A(:,nx),'-r',time,(A(:,RXY(1,nx))-RXY(3,nx))/RXY(2,nx),'-black');

legend('拟合模型','实际','稳态模型');

figure(2)
plot( [(M(:,nx)-A(:,nx))/DataJudgement(2,nx)  ((A(:,RXY(1,nx))-RXY(3,nx))/RXY(2,nx)-A(:,nx))/DataJudgement(2,nx) ]);
legend('拟合误差','稳态误差');