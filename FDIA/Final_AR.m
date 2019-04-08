%���Ա���w���䷽����GROUSE�㷨Ч����
%
clear;
close all;
%��������
load Data01.mat;
load DataJudgement.mat;
load ab.mat
% DataJudgement=[DataJudgement;mean(DataJudgement)];
%�ܱ�����,����n��������
n=8;
A=A(:,1:n);
M1=zeros(size(A));
M2=zeros(size(A));
Time1=zeros(size(A));
Time2=zeros(size(A));
tfault=floor(length(M1)/5)*10;
%%��ʼ����
m=30;maxrank=6;
%Ȩ��ϵ������
Psai0=diag([ones(1,m)]);
ttotal=length(A);
for nx=1:8
P=10^6.*eye(n,n);
U =orth(randn(m,maxrank));
%Ԥ��������ù۲����
Omega=ones(m,n);
Omega(m,nx)=0;
sx=[1:n];
sx(nx)=[];
ab=ones(n,1);
for k=m:ttotal
    %����δ����ʱ������ģ��
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
            %����H: z=Hx+e,1*7
            H=[NMk(m-1,sx) ones(1,1)];
            %====������������====
            Q=0.000*eye(n,n);
            R=0.01*eye(1,1);
            %====����Э�������Pguess:7*7====
            Pguess=Aab*P*Aab'+Q; 
            %====��������K:====
            K=Pguess*H'/(H*Pguess*H'+R);
            %====����Э�������====
            P=(eye(n)-K*H)*Pguess;     
            %====״̬����====
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