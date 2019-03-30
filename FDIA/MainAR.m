clear;
close all;
%加载数据
load Data01.mat;
load DataJudgement.mat;

%总变量数,根据n载入数据
n=8;
M=A(:,1:n);
Mc=zeros(size(M));
for AR_Sensor=1:n
%参数矩阵周期数,子空间维数,初始化子空间
m=30;maxrank=6;
U =orth(randn(m,maxrank));
%预测对象，设置观测矩阵
% AR_Sensor=[2];
Omega=ones(m,n);
Omega(m,AR_Sensor)=0;
%权重系数矩阵
Psai0=diag([ones(1,m)]);
%  Psai0=diag([1:0.04:2.16]);


%%开始仿真
% Mc=M;
for k=m:length(M)
  %提取参数矩阵
  Mk=M(k-m+1:k,:);
  %归一化
  [NMk,minMk,maxMk]=NormalData(Mk);
  %设置
  [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,AR_Sensor);
  %反归一化
  [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
  Mc(k,AR_Sensor)=Mkc(m,AR_Sensor);
%   M(k,AR_Sensor)=Mc(k,AR_Sensor);
end
end

MainAR_Plot;