%测试在线建模方法的效果。
%由一定效果，但精度要远逊于GROUSE，两者对问题的描述是类似的，但是对子空间的求解方式不一样。

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
%定义观测的到参数矩阵
A=A(:,:);
M=A;
%tfault个点之后，数据丢失
tfault=10000;
% M(tfault:length(M),nx)=0;
P=10^6.*eye(8,8);
m=30;
%%开始仿真
sx=[1:n];
sx(nx)=[];
% sx=1:6;
ab=ones(8,1);
ab=[A(1:100,sx) ones(100,1)]\A(1:100,nx);
for k=m:length(M)
  %当故障未发生时，利用卡尔曼滤波更新模型
%   if  abs((A(k,nx)-[A(k,ns) 1]*ab))>0.01*DataJudgement(2,nx)
    %====计算模型参数====
    %计算 A: x=Ax,7*7
    Mk=A(k-m+1:k,:);
    [NMk,minMk,maxMk]=NormalData(Mk);
%     NMk=Mk;
    Aab=eye(8,8);
    %计算H: z=Hx+e,1*7
    H=[NMk(1:m-1,sx) ones(m-1,1)];
    %====定义噪声参数====
    Q=0.001*eye(8,8);
    R=0.001*eye(29,29);
    %====估计协方差矩阵Pguess:7*7====
    Pguess=Aab*P*Aab'+Q;
    %====计算增益K:====
    K=Pguess*H'/(H*Pguess*H'+R);
    %====更新协方差矩阵====
    P=(eye(8)-K*H)*Pguess;     
    %====状态更新====
    ab=ab+K*(NMk(1:m-1,nx)-H*ab);
    %当故障发生时，利用当前模型产生重构信号
    
%   end
  
%   ab=[NMk(1:m-1,sx) ones(m-1,1)]\NMk(1:m-1,nx);
  NMk(m,nx)=[NMk(m,sx) 1]*ab;
  [Mkc]=AntiNormalData(NMk,minMk,maxMk);
%   Mkc=NMk;
  M(k,nx)=Mkc(m,nx);
  
end

figure(1)
time=1:length(M);

plot(time,M(:,nx),'-b',time,A(:,nx),'-r');

legend('拟合模型','实际');
xlim([m+10 length(M)]);
figure(2)
plot( (M(:,nx)-A(:,nx))/DataJudgement(2,nx));
legend('拟合误差','稳态误差');
xlim([m+10 length(M)]);