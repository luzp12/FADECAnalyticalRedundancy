clear;
close all;
%加载数据
load Data01.mat;
load DataJudgement.mat;
load RXY.mat;

% ny=3;
% rxy=polyfit(A(:,nx),A(:,ny),1);
% figure(4)
% plot(A(:,nx),A(:,ny),'.r',A(:,nx),rxy(1,1).*A(:,nx)+rxy(1,2),'.b');
%总变量数,根据n载入数据
n=8;
nx=8;
M=A(:,1:n);
Data=M;
% M(600:length(A),nx)=0;
M=M';
Mc=zeros(size(M));
%1:n-1
%参数矩阵周期数,子空间维数,初始化子空间
m=8;maxrank=5;
U =orth(randn(n,maxrank));
%预测对象，设置观测矩阵
% AR_Sensor=[2];
Omega=ones(n,m);
Omega(nx,m)=0;
%权重系数矩阵
Psai0=diag([ones(1,nx)]);
%  Psai0=diag([1:0.04:2.16]);
P=10^6.*eye(m-1,m-1);
 NoUpdate=[];
%%开始仿真
% Mc=M;
for k=m:length(M)
  %提取参数矩阵
  if k<20*m
  AR_Sensor=[];
  else
  AR_Sensor=nx;
  Omega(nx,1:m)=0;
%       if m-k+20*m>=1
%       Omega(m-k+20*m,AR_Sensor)=0;
%       else
%           NoUpdate=nx;
%       end
  end
%   S_Sensor=1:8;
%   S_Sensor(AR_Sensor)=[];
  Mk=M(:,k-m+1:k);
  %归一化
  [NMk,minMk,maxMk]=NormalData(Mk');
  %设置
  
  [NMkc,U]=ARbyGROUSE(U,NMk',Omega,maxrank,Psai0,[]);
  %反归一化
  [Mkc]=AntiNormalData(NMkc',minMk,maxMk);
  Mc(:,k-m+1:k)=Mkc';
  if k>=20*m
  M(AR_Sensor,k-m+1:k)=Mc(AR_Sensor,k-m+1:k);
  
  end
%   Mc(k-m+1:k,:)=Mkc;
%   if k>=20*m
%     %===============卡尔曼滤波器=================
%     %  STEP1:计算模型参数
%     %计算 A: x=Ax
%     U1=U(1:m-1,:);
%     U2=U(2:m,:);
%     A=U2/(U1'*U1)*U1';
% %     U2=U(m,:);
% %     A=[zeros(m-2,1) eye(m-2,m-2);U2/(U1'*U1)*U1'];
%     [~,lambda]=eig(A);
%     rou=max(max(abs(lambda)));
%     %计算H: z=Hx+e
%     H=RXY(2,AR_Sensor)*eye(m-1,m-1);
%     %     %定义参数
%     Q=diag([zeros(1,m-2) 1]);%1*eye(m-1,m-1);
%     R=diag([ones(1,m-2) 0.5]);%0.5*eye(m-1,m-1);
% 
%     %估计协方差矩阵Pguess:m-1*m-1
%     
%     Pguess=A*P*A'+Q;
% 
%     %计算增益K:
%     K=Pguess*H'/(H*Pguess*H'+R);
% 
%     %更新协方差矩阵
%     P=(eye(m-1)-K*H)*Pguess;     
% %     %状态更新
%     M_guess=A*M(k-m+1:k-1,AR_Sensor);%Ms3nH(49,1);
%     M_update=M_guess+K*(Data(k-m+2:k,RXY(1,AR_Sensor))-RXY(3,AR_Sensor)-H*M_guess(1:m-1,1));
% 
%     M(k,nx)=M_update(m-1,1);
%     M(1:20*m-1,:)=Data(1:20*m-1,:);
%   end
end
% ny=RXY(1,AR_Sensor);

figure(1)
% for AR_Sensor=1:n-1
    time=1:length(M(AR_Sensor,:));
% subplot(4,2,AR_Sensor)
plot(time,M(AR_Sensor,:),'-b',time,Data(:,AR_Sensor),'-r');

% xlim([20*m k-m]);
% ylim([min(Data(:,AR_Sensor))  max(Data(:,AR_Sensor))])
% end
legend('滤波估计','实际');

figure(2)
plot( (Mc(AR_Sensor,:)-Data(:,AR_Sensor)')/DataJudgement(2,AR_Sensor));
 legend('滤波估计');
% xlim([20*m  k-m]);
% 
% fprintf('Average error of KF ：%d \n',norm(abs((M(:,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor)))/length(time));
% fprintf('Max error of KF ：%d \n',max(abs((M(:,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor))));
% fprintf('Average error of SM ：%d \n',norm( abs(((M(:,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor)))/length(time));
% fprintf('Max error of SM ：%d \n',max( abs(((M(:,RXY(1,AR_Sensor))-RXY(3,AR_Sensor))/RXY(2,AR_Sensor)-Data(:,AR_Sensor))/DataJudgement(2,AR_Sensor))));