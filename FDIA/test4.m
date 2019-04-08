%���Ա���w���䷽����GROUSE�㷨Ч����
%

clear;
close all;
%��������
load Data01.mat;
load DataJudgement.mat;
load RXY.mat;
load ab.mat

%�ܱ�����,����n��������
n=8;
nx=8;
%����۲�ĵ���������
A=A(:,:);
M=A;
%tfault����֮�����ݶ�ʧ
tfault=1000;
% M(tfault:length(M),nx)=0;
m=30;
%%��ʼ����
m=30;maxrank=6;
U =orth(randn(m,maxrank));
%Ԥ��������ù۲����
% AR_Sensor=[2];
Omega=ones(m,n);
Omega(m,nx)=0;
%Ȩ��ϵ������
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

legend('���ģ��','ʵ��');
xlim([m+10 length(M)]);
figure(2)
plot( (M(:,nx)-A(:,nx))/DataJudgement(2,nx));
legend('������','��̬���');
xlim([m+10 length(M)]);