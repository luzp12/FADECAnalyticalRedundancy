%测试保留w不变方法的GROUSE算法效果。
%
clear;
close all;
%加载数据
load Data01.mat;
load DataJudgement.mat;
load ab.mat
% DataJudgement=[DataJudgement;mean(DataJudgement)];
%总变量数,根据n载入数据
n=8;
A=A(:,1:n);
M1=zeros(size(A));
M2=zeros(size(A));
Time1=zeros(size(A));
Time2=zeros(size(A));
tfault=floor(length(M1)/5)*10;
%%开始仿真
m=30;maxrank=6;
%权重系数矩阵
Psai0=diag([ones(1,m)]);
ttotal=length(A);
for nx=1:8
P=10^6.*eye(n,n);
U =orth(randn(m,maxrank));
%预测对象，设置观测矩阵
Omega=ones(m,n);
Omega(m,nx)=0;
sx=[1:n];
sx(nx)=[];
ab=ones(n,1);
for k=m:ttotal
    %故障未发生时，更新模型
        if k<tfault
            %GROUSE
            Mk=A(k-m+1:k,:);
            [NMk,minMk,maxMk]=NormalData(Mk,DataJudgement);
            tic
            [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,[]);
            [Mkc]=AntiNormalData(NMkc,minMk,maxMk);
            M1(k,nx)=Mkc(m,nx);
            Time1(k,nx)=toc;
            w=U\NMk;
            %Online Model Identification
            tic
            Aab=eye(n,n);
            %计算H: z=Hx+e,1*7
            H=[NMk(m-1,sx) ones(1,1)];
            %====定义噪声参数====
            Q=0.000*eye(n,n);
            R=0.01*eye(1,1);
            %====估计协方差矩阵Pguess:7*7====
            Pguess=Aab*P*Aab'+Q; 
            %====计算增益K:====
            K=Pguess*H'/(H*Pguess*H'+R);
            %====更新协方差矩阵====
            P=(eye(n)-K*H)*Pguess;     
            %====状态更新====
            ab=ab+K*(NMk(m-1,nx)-H*ab);
            NMkc2=NMk;
            NMkc2(m,nx)=[NMk(m,sx) 1]*ab;
            [Mkc2]=AntiNormalData(NMkc2,minMk,maxMk);
            M2(k,nx)=Mkc2(m,nx);
            Time2(k,nx)=toc;
        else  
            %GROUSE
            Mk=A(k-m+1:k,:);
            [NMk,minMk,maxMk]=NormalData(Mk);
            [NMkc,U]=ARbyGROUSE(U,NMk,Omega,maxrank,Psai0,nx);
            [Mkc]=AntiNormalData(NMk,minMk,maxMk);
            [Mkc2]=AntiNormalData(NMkc2,minMk,maxMk);
            M1(k,nx)=Mkc(m,nx);
            %Online Model Identification
            NMkc2(m,nx)=[NMk(m,sx) 1]*ab;
            [Mkc2]=AntiNormalData(NMkc2,minMk,maxMk);
            M2(k,nx)=Mkc2(m,nx);
        end
        
  
end
end
Final_AR_Plot;