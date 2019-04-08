%测试保留w不变方法的GROUSE算法效果。
%

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
tfault=1000;
% M(tfault:length(M),nx)=0;
m=30;
%%开始仿真
m=30;maxrank=6;
U =orth(randn(m,maxrank));
%预测对象，设置观测矩阵
% AR_Sensor=[2];
Omega=ones(m,n);
Omega(m,nx)=0;
%权重系数矩阵
Psai0=diag([ones(1,m)]);

for k=m:length(M)
        if k<tfault
        Mk=A(k-m+1:k,:);
        [NMk,minMk,maxMk]=NormalData(Mk);
        [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,[]);
        [Mkc]=AntiNormalData(NMk,minMk,maxMk);
        M(k,nx)=Mkc(m,nx);
        w=U\NMk;
        else
            
        Mk=A(k-m+1:k,:);
        [NMk,minMk,maxMk]=NormalData(Mk);
        [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,nx);
        [Mkc]=AntiNormalData(NMk,minMk,maxMk);
            NMkc2=U*w;
            [Mkc2]=AntiNormalData(NMkc2,minMk,maxMk);
            M(k,nx)=Mkc2(m,nx);
        end
        
  
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